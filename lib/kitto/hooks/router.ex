defmodule Kitto.Hooks.Router do
  use Plug.Router

  if Mix.env == :dev, do: use Plug.Debugger, otp_app: :kitto
  unless Mix.env == :test, do: plug Plug.Logger

  plug :match
  plug :dispatch

  match _ do
    send_resp(conn, 200, "Running hook for #{conn.request_path}")
  end
end
