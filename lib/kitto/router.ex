defmodule Kitto.Router do
  use Plug.Router

  if Mix.env == :dev, do: use Plug.Debugger, otp_app: :kitto
  unless Mix.env == :test, do: plug Plug.Logger

  plug Kitto.Plugs.Authentication

  plug :match
  if Mix.env == :prod do
    plug Plug.Static, at: "assets", gzip: true, from: Path.join "public", "assets"
  end
  plug :dispatch

  get "/", do: conn |> redirect_to_default_dashboard
  get "dashboards", do: conn |> redirect_to_default_dashboard

  get "dashboards/:id" do
    if Kitto.View.exists?(id) do
      conn |> render(id)
    else
      send_resp(conn, 404, "Dashboard \"#{id}\" does not exist")
    end
  end

  get "events" do
    conn = initialize_sse(conn)
    Kitto.Notifier.register(conn.owner)
    conn = listen_sse(conn)

    conn
  end

  post "widgets/:id" do
    {:ok, body, conn} = read_body(conn)

    Kitto.Notifier.broadcast!(id, body |> Poison.decode!)

    conn |> send_resp(204, "")
  end

  get "assets/*asset" do
    if Mix.env == :dev do
      conn = conn |> redirect_to("#{development_assets_url}#{asset |> Enum.join("/")}")
    else
      send_resp(conn, 404, "Not Found") |> halt
    end
  end

  defp initialize_sse(conn) do
    conn
    |> put_resp_header("content-type", "text/event-stream")
    |> put_resp_header("cache-control", "no-cache")
    |> put_resp_header("x-accel-buffering", "no")
    |> send_chunked(200)
    |> send_cached_events
  end

  match _, do: send_resp(conn, 404, "Not Found")

  defp render(conn, template), do: send_resp(conn, 200, Kitto.View.render(template))

  defp listen_sse(conn) do
    receive do
      {:broadcast, {topic, data}} ->
        res = send_event(conn, topic, data)

        case res do
          :closed -> conn |> halt
          _ -> res |> listen_sse
        end
      {:error, :closed} -> conn |> halt
      {:misc, :close} -> conn |> halt
      _ -> listen_sse(conn)
    end
  end

  defp send_event(conn, topic, data) do
    {_, conn} = chunk(conn, (["event: #{topic}",
                              "data: {\"message\": #{Poison.encode!(data)}}"]
                             |> Enum.join("\n")) <> "\n\n")

    conn
  end

  defp send_cached_events(conn) do
    Kitto.Notifier.initial_broadcast!(conn.owner)

    conn
  end

  defp redirect_to(conn, path) do
    conn
    |> put_resp_header("location", path)
    |> send_resp(301, "")
    |> halt
  end

  defp redirect_to_default_dashboard(conn) do
    conn |> redirect_to("/dashboards/" <> default_dashboard)
  end

  defp default_dashboard, do: Application.get_env(:kitto, :default_dashboard, "sample")

  defp development_assets_url do
    "http://#{Kitto.asset_server_host}:#{Kitto.asset_server_port}/assets/"
  end
end
