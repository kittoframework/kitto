defmodule Kitto.Hook.Router do
  @moduledoc """
  Handles requests to the Kitto Hooks API.
  """

  use Plug.Router

  alias Kitto.Runner

  if Application.get_env(:kitto, :debug), do: use Plug.Debugger, otp_app: :kitto
  unless Mix.env == :test, do: plug Plug.Logger
  use Plug.ErrorHandler

  plug :match
  plug :dispatch

  match "/:id" do
    case Runner.hook(:runner, id) do
      nil -> conn |> send_resp(404, "No hook defined for /#{id}")
      hook ->
        hook[:hook].()
        conn |> send_resp(204, "")
    end
  end
end
