defmodule Kitto.Hooks.Router do
  use Plug.Router

  alias Kitto.{Notifier,Hooks}

  if Mix.env == :dev, do: use Plug.Debugger, otp_app: :kitto
  unless Mix.env == :test, do: plug Plug.Logger

  plug :match
  plug :dispatch

  match "/:hook" do
    if Hooks.hooks[String.to_atom hook] do
      Hooks.hooks[String.to_atom hook].(conn)
    else
      {:ok, body, _} = read_body conn
      data = body |> Poison.decode!
      Notifier.broadcast! String.to_atom(hook), data
    end

    send_resp(conn, 200, "Running hook for #{conn.request_path}")
  end

  match _ do
    send_resp(conn, 404, "No handler found for request.")
  end
end
