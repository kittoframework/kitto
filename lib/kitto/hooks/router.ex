defmodule Kitto.Hooks.Router do
  use Plug.Router

  alias Kitto.{Notifier, Registry}

  if Mix.env == :dev, do: use Plug.Debugger, otp_app: :kitto
  unless Mix.env == :test, do: plug Plug.Logger

  plug Plug.Parsers, parsers: [:urlencoded, :json, :multipart], json_decoder: Poison

  plug :match
  plug :dispatch

  match "/:hook_id" do
    case Registry.hook(conn.private.registry, hook_id) do
      {_options, block, _context} -> block.(conn)
      _ -> Notifier.broadcast! hook_id, params(conn)
    end

    send_resp(conn, 200, "Hook successful.")
  end

  match _ do
    send_resp(conn, 404, "No handler found for request.")
  end

  def params(conn) do
    if Enum.empty?(conn.body_params), do: conn.query_params, else: conn.body_params
  end
end
