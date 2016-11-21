defmodule Kitto.Endpoints.Dashboard do
  @moduledoc """
  Routes to interact with dashboards. Mounted at `/dashboards`.
  """

  use Plug.Router

  if Mix.env == :dev, do: use Plug.Debugger, otp_app: :kitto
  unless Mix.env == :test, do: plug Plug.Logger

  plug :match
  plug Kitto.Plugs.Authentication
  plug :dispatch

  # Open the default dashboard
  #
  # Set the default dashboard with the `default_dashboard` key in your
  # application's config:
  #
  #     # config/config.exs
  #     config :kitto, default_dashboard: "general"
  get "/", do: conn |> redirect_to_default_dashboard

  # Opens a specific dashboard.
  get "/:id" do
    if Kitto.View.exists?(id) do
      conn |> render(id)
    else
      conn |> send_resp(404, "Dashboard \"#{id}\" does not exist")
    end
  end

  # Reload all dashboards across all clients
  #
  # *Note: This route requires token authentication if enabled.*
  post "/", private: %{authenticated: true} do
    {:ok, body, conn} = read_body conn
    command = body |> Poison.decode! |> Map.put_new("dashboard", "*")
    Kitto.Notifier.broadcast!("_kitto", command)

    conn |> send_resp(204, "")
  end

  # Reload a specific dashboard across all clients
  #
  # *Note: This route requires token authentication if enabled.*
  post "/:id", private: %{authenticated: true} do
    {:ok, body, conn} = read_body conn
    command = body |> Poison.decode! |> Map.put("dashboard", id)
    Kitto.Notifier.broadcast! "_kitto", command

    conn |> send_resp(204, "")
  end

  @doc """
  Redirects user to the default dashboard. The default dashboard can be
  configured throue the applications config:

      # config/config.exs
      config :kitto, default_dashboard: "general"

  Default if unconfigured: sample
  """
  def redirect_to_default_dashboard(conn) do
    conn |> redirect_to("/dashboards/" <> default_dashboard)
  end

  defp render(conn, template), do: send_resp(conn, 200, Kitto.View.render(template))

  defp redirect_to(conn, path) do
    conn
    |> put_resp_header("location", path)
    |> send_resp(301, "")
    |> halt
  end

  defp default_dashboard, do: Application.get_env(:kitto, :default_dashboard, "sample")
end
