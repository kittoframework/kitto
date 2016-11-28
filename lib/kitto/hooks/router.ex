defmodule Kitto.Hooks.Router do
  use Plug.Router

  alias Kitto.{Notifier, Hooks}

  if Mix.env == :dev, do: use Plug.Debugger, otp_app: :kitto
  unless Mix.env == :test, do: plug Plug.Logger

  plug :match
  plug :dispatch

  match "/:hook_id" do
    if hook?(hook_id) do
      hook(hook_id).(conn)
    else
      {:ok, body, _} = read_body conn
      data = body |> Poison.decode!
      Notifier.broadcast! String.to_atom(hook_id), data
    end

    send_resp(conn, 200, "Running hook for #{conn.request_path}")
  end

  match _ do
    send_resp(conn, 404, "No handler found for request.")
  end

  defp hook(hook_id), do: Hooks.hooks[String.to_atom(hook_id)]
  defp hook?(hook_id), do: !!hook(hook_id)
end
