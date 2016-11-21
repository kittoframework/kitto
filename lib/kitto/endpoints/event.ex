defmodule Kitto.Endpoints.Event do
  @moduledoc """
  Event router to build SSE connections for client
  """

  use Plug.Router

  if Mix.env == :dev, do: use Plug.Debugger, otp_app: :kitto
  unless Mix.env == :test, do: plug Plug.Logger

  plug :match
  plug Kitto.Plugs.Authentication
  plug :dispatch

  # Initialize SSE connection
  get "/" do
    conn = initialize_sse(conn)
    Kitto.Notifier.register(conn.owner)
    conn = listen_sse(conn)

    conn
  end

  defp initialize_sse(conn) do
    conn
    |> put_resp_header("content-type", "text/event-stream")
    |> put_resp_header("cache-control", "no-cache")
    |> put_resp_header("x-accel-buffering", "no")
    |> send_chunked(200)
    |> send_cached_events
  end

  defp listen_sse(conn) do
    receive do
      {:broadcast, {topic, data}} ->
        res = send_event(conn, topic, data)

        case res do
          :closed -> conn |> halt
          _ -> res |> listen_sse
        end
      {:error, :closed} -> conn |> halt
      {:misc, :close} -> conn |> halt
      _ -> listen_sse(conn)
    end
  end

  defp send_event(conn, topic, data) do
    {_, conn} = chunk(conn, (["event: #{topic}",
                              "data: {\"message\": #{Poison.encode!(data)}}"]
                             |> Enum.join("\n")) <> "\n\n")

    conn
  end

  defp send_cached_events(conn) do
    Kitto.Notifier.initial_broadcast!(conn.owner)

    conn
  end
end
