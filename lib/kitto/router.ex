defmodule Kitto.Router do
  use Plug.Router

  alias Kitto.{View, Notifier}

  if Application.get_env(:kitto, :debug), do: use Plug.Debugger, otp_app: :kitto
  unless Mix.env == :test, do: plug Plug.Logger
  use Plug.ErrorHandler

  plug :match
  plug Kitto.Plugs.Authentication

  if Application.get_env(:kitto, :serve_assets?, true) do
    plug Plug.Static,
         at: "assets",
         gzip: true,
         from: Application.get_env(:kitto, :assets_path) || Application.get_env(:kitto, :otp_app)
  end

  plug :dispatch

  get "/", do: conn |> redirect_to_default_dashboard
  get "dashboards", do: conn |> redirect_to_default_dashboard

  get "dashboards/rotator" do
    conn = conn |> fetch_query_params
    query_params = conn.query_params
    dashboards = String.split(query_params["dashboards"], ",")
    interval = query_params["interval"] || 60

    if View.exists?("rotator") do
      conn |> render("rotator", [dashboards: dashboards, interval: interval])
    else
      info = "Rotator template is missing.
              See: https://github.com/kittoframework/kitto/wiki/Cycling-Between-Dashboards
              for instructions to enable cycling between dashboards."

      send_resp(conn, 404, info)
    end
  end

  get "dashboards/*id" do
    path = Enum.join(id, "/")

    if View.exists?(path) do
      conn
      |> put_resp_header("content-type", "text/html")
      |> render(path)
    else
      render_error(conn, 404, "Dashboard does not exist")
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
  get "widgets/:id", do: conn |> render_json(Notifier.cache[id])

  post "widgets/:id", private: %{authenticated: true} do
    {:ok, body, conn} = read_body(conn)

    Notifier.broadcast!(id, body |> Poison.decode!)

    conn |> send_resp(204, "")
  end

  get "assets/*asset" do
    if Kitto.watch_assets? do
      conn |> redirect_to("#{development_assets_url()}#{asset |> Enum.join("/")}")
    else
      conn |> render_error(404, "Not Found") |> halt
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

  match _, do: render_error(conn, 404, "Not Found")

  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}),
    do: render_error(conn, 500, "Something went wrong")

  defp render(conn, template, bindings \\ []),
    do: send_resp(conn, 200, View.render(template, bindings))

  defp render_error(conn, code, message),
    do: send_resp(conn, code, View.render_error(code, message))

  defp listen_sse(conn, :""), do: listen_sse(conn, nil)
  defp listen_sse(conn, topics) do
    receive do
      {:broadcast, {topic, data}} ->
        res = case is_nil(topics) || to_string(topic) in topics do
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
    conn |> redirect_to("/dashboards/" <> default_dashboard())
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
         |> String.split(",") do
      [""] -> nil
      topics -> MapSet.new(topics)
    end
  end
end
