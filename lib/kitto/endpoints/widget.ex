defmodule Kitto.Endpoints.Widget do
  @moduledoc """
  Routes to interact with widgets. Mounted at `/widgets`.
  """

  use Plug.Router

  if Mix.env == :dev, do: use Plug.Debugger, otp_app: :kitto
  unless Mix.env == :test, do: plug Plug.Logger

  plug :match
  plug Kitto.Plugs.Authentication
  plug :dispatch

  # Get's the full data cache
  get "/", do: conn |> render_json(Kitto.Notifier.cache)

  # Get's a single dataset from the cache
  get "/:id", do: conn |> render_json(Kitto.Notifier.cache[String.to_atom(id)])

  # Broadcasts an event based on the requested path
  #
  # *Note: This route requires token authentication if enabled.*
  post "/:id", private: %{authenticated: true} do
    {:ok, body, conn} = read_body(conn)

    Kitto.Notifier.broadcast!(id, body |> Poison.decode!)

    conn |> send_resp(204, "")
  end

  defp render_json(conn, json, opts \\ %{status: 200}) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(opts.status, Poison.encode!(json))
  end
end
