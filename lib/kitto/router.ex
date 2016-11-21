defmodule Kitto.Router do
  use Plug.Router

  if Mix.env == :dev, do: use Plug.Debugger, otp_app: :kitto
  unless Mix.env == :test, do: plug Plug.Logger

  plug :match
  plug Kitto.Plugs.Authentication
  if Mix.env == :prod do
    plug Plug.Static, at: "assets", gzip: true, from: Path.join "public", "assets"
  end
  plug :dispatch

  get "/", do: conn |> Kitto.Endpoints.Dashboard.redirect_to_default_dashboard

  forward "/dashboards", to: Kitto.Endpoints.Dashboard
  forward "/widgets", to: Kitto.Endpoints.Widget
  forward "/events", to: Kitto.Endpoints.Event

  get "assets/*asset" do
    if Kitto.asset_server_enabled? do
      conn = conn |> redirect_to("#{development_assets_url}#{asset |> Enum.join("/")}")
    else
      send_resp(conn, 404, "Not Found") |> halt
    end
  end

  match _, do: send_resp(conn, 404, "Not Found")

  defp redirect_to(conn, path) do
    conn
    |> put_resp_header("location", path)
    |> send_resp(301, "")
    |> halt
  end

  defp development_assets_url do
    "http://#{Kitto.asset_server_host}:#{Kitto.asset_server_port}/assets/"
  end
end
