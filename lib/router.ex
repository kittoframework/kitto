defmodule Kitto.Router do
  use Plug.Router

  @development_assets_url "http://localhost:8080/assets/"

  if Mix.env == :dev, do: use Plug.Debugger, otp_app: :kitto

  plug Plug.Logger
  plug :match
  if Mix.env == :prod do
    plug Plug.Static, at: "assets", from: Path.join "public", "assets"
  end
  plug :dispatch

  get "dashboards/:id", do: conn |> render(id)

  get "events" do
    conn = initialize_sse(conn)
    Kitto.Notifier.register(conn.owner)
    listen_sse(conn)

    conn
  end

  post "widgets/:id" do
    {:ok, body, conn} = read_body(conn)

    Kitto.Notifier.broadcast!(id, body |> Poison.decode!)

    conn |> send_resp(204, "")
  end

  if Mix.env == :dev do
    get "assets/:asset" do
      conn
      |> put_resp_header("location", "#{@development_assets_url}#{asset}")
      |> send_resp(301, "")

      conn
    end
  end

  defp initialize_sse(conn) do
    conn
    |> put_resp_header("content-type", "text/event-stream")
    |> put_resp_header("cache-control", "no-cache")
    |> put_resp_header("x-accel-buffering", "no")
    |> send_chunked(200)
  end

  match _, do: send_resp(conn, 404, "Not Found")

  defp render(conn, template), do: send_resp(conn, 200, Kitto.View.render(template))

  defp listen_sse(conn) do
    receive do
      {:broadcast, {topic, data}} -> send_event(conn, topic, data)
      {:error, :closed} -> IO.puts "Connection was closed"
    end

    listen_sse(conn)
  end

  defp send_event(conn, topic, data) do
    chunk(conn, "event: #{topic}\ndata: {\"message\": #{Poison.encode!(data)}}\n\n")

    conn
  end
end
