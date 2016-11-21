defmodule Kitto.Router do
  use Plug.Router

  alias Kitto.View
  alias Kitto.Notifier
  alias Kitto.View

  if Mix.env == :dev, do: use Plug.Debugger, otp_app: :kitto
  unless Mix.env == :test, do: plug Plug.Logger

  plug :match
  plug Kitto.Plugs.Authentication
  if Mix.env == :prod do
    plug Plug.Static, at: "assets", gzip: true, from: Path.join "public", "assets"
  end
  plug :dispatch

  get "/", do: conn |> redirect_to_default_dashboard
  get "dashboards", do: conn |> redirect_to_default_dashboard

  get "dashboards/:id" do
    if View.exists?(id) do
      conn |> render(id)
    else
      send_resp(conn, 404, "Dashboard \"#{id}\" does not exist")
    end
  end

  post "dashboards", private: %{authenticated: true} do
    {:ok, body, conn} = read_body conn
    command = body |> Poison.decode! |> Map.put_new("dashboard", "*")
    Notifier.broadcast! "_kitto", command

    conn |> send_resp(204, "")
  end

  post "dashboards/:id", private: %{authenticated: true} do
    {:ok, body, conn} = read_body conn
    command = body |> Poison.decode! |> Map.put("dashboard", id)
    Notifier.broadcast! "_kitto", command

    conn |> send_resp(204, "")
  end

  get "events" do
    conn = initialize_sse(conn)

    Notifier.register(conn.owner)
    conn = listen_sse(conn, subscribed_topics(conn))

    conn
  end

  get "widgets", do: conn |> render_json(Notifier.cache)
  get "widgets/:id", do: conn |> render_json(Notifier.cache[String.to_atom(id)])

  post "widgets/:id", private: %{authenticated: true} do
    {:ok, body, conn} = read_body(conn)

    Notifier.broadcast!(id, body |> Poison.decode!)

    conn |> send_resp(204, "")
  end

  get "assets/*asset" do
    if Mix.env == :dev do
      conn = conn |> redirect_to("#{development_assets_url}#{asset |> Enum.join("/")}")
    else
      conn |> send_resp(404, "Not Found") |> halt
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

  defp render(conn, template), do: send_resp(conn, 200, View.render(template))

  defp listen_sse(conn, :""), do: listen_sse(conn, nil)
  defp listen_sse(conn, topics) do
    receive do
      {:broadcast, {topic, data}} ->
        res = case is_nil(topics) || topic in topics do
          true -> send_event(conn, topic, data)
          false -> conn
        end

        case res do
          :closed -> conn |> halt
          _ -> res |> listen_sse(topics)
        end
      {:error, :closed} -> conn |> halt
      {:misc, :close} -> conn |> halt
      _ -> listen_sse(conn, topics)
    end
  end

  defp send_event(conn, topic, data) do
    {_, conn} = chunk(conn, (["event: #{topic}",
                              "data: {\"message\": #{Poison.encode!(data)}}"]
                             |> Enum.join("\n")) <> "\n\n")

    conn
  end

  defp send_cached_events(conn) do
    Notifier.initial_broadcast!(conn.owner)

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

  defp render_json(conn, json, opts \\ %{status: 200}) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(opts.status, Poison.encode!(json))
  end

  defp subscribed_topics(conn) do
    case Plug.Conn.fetch_query_params(conn).query_params
         |> Map.get("topics", "")
         |> String.split(",")
         |> Enum.map(&String.to_atom/1) do
      [:""] -> nil
      topics -> MapSet.new(topics)
    end
  end
end
