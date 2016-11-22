defmodule Kitto.Hooks.Router do
  use Plug.Router

  if Mix.env == :dev, do: use Plug.Debugger, otp_app: :kitto
  unless Mix.env == :test, do: plug Plug.Logger

  plug :match
  plug :dispatch

  match "/:hook" do
    if Kitto.Hooks.hooks[String.to_atom hook] do
      Kitto.Hooks.hooks[String.to_atom hook].(conn)
    else
      {:ok, body, _} = read_body conn
      data = body |> Poison.decode!
      Kitto.Notifier.broadcast! String.to_atom(hook), data
    end

    send_resp(conn, 200, "Running hook for #{conn.request_path}")
  end

  match _ do
    send_resp(conn, 404, "No handler found for request.")
  end
end
