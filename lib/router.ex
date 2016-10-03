defmodule Kitto.Router do
  use Plug.Router

  @development_assets_url "http://localhost:8080/assets/"

  if Mix.env == :dev, do: use Plug.Debugger, otp_app: :kitto

  plug Plug.Logger
  plug :match
  if Mix.env == :prod do
    plug Plug.Static, at: "assets", gzip: true, from: Path.join "public", "assets"
  end
  plug :dispatch

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

  get "assets/:asset" do
    if Mix.env == :dev do
      conn = conn
      |> put_resp_header("location", "#{@development_assets_url}#{asset}")
      |> send_resp(301, "")
      |> halt
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
  end

  match _, do: send_resp(conn, 404, "Not Found")

  defp render(conn, template), do: send_resp(conn, 200, Kitto.View.render(template))

  defp listen_sse(conn) do
    receive do
      {:broadcast, {topic, data}} ->
        send_event(conn, topic, data) |> listen_sse
      {:error, :closed} -> conn |> halt
      {:misc, :close} -> conn |> halt
      _ -> listen_sse(conn)
    end
  end

  defp send_event(conn, topic, data) do
    {_, conn} = chunk(conn, "event: #{topic}\ndata: {\"message\": #{Poison.encode!(data)}}\n\n")

    conn
  end
end
