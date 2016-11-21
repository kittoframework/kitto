defmodule Kitto.RouterTest do
  use ExUnit.Case
  use Plug.Test

  import ExUnit.CaptureIO
  import Mock

  @opts Kitto.Router.init([])

  test "GET with unrecognized request path responds with 404 Not Found" do
    conn = conn(:get, "/nope")

    conn = Kitto.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "Not Found"
  end

  test "GET / with :default_dashboard left unconfigured redirects to dashboards/sample" do
    conn = conn(:get, "/")
    Application.delete_env :kitto, :default_dashboard
    conn = Kitto.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 301
    assert (conn |> get_resp_header("location") |> hd) == "/dashboards/sample"
  end

  test "GET / with :default_dashboard configured redirects to the configured dashboard" do
    conn = conn(:get, "/")

    Application.put_env :kitto, :default_dashboard, "jobs"
    conn = Kitto.Router.call(conn, @opts)
    Application.delete_env :kitto, :default_dashboard

    assert conn.state == :sent
    assert conn.status == 301
    assert (conn |> get_resp_header("location") |> hd) == "/dashboards/jobs"
  end

  test "GET /assets outside of development mode renders 404" do
    conn = conn(:get, "/assets/style.css")
    |> Kitto.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end

  test "GET /assets in dev mode redirects to asset server" do
    with_mock Kitto, [:passthrough], [asset_server_enabled?: fn () -> true end] do
      conn = conn(:get, "/assets/style.css")
      |> Kitto.Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 301
    end
  end

  test "GET /dashboards forwards to Dashboard endpoint" do
    conn = conn(:get, "/dashboards")
    |> Kitto.Router.call(@opts)

    assert conn.state == :sent
    assert String.contains?(capture_io(fn ->
      IO.inspect(conn.private.plug_route)
    end), "Kitto.Endpoints.Dashboard")
  end

  test "GET /widgets forwards to Widget endpoint" do
    conn = conn(:get, "/widgets")
    |> Kitto.Router.call(@opts)

    assert conn.state == :sent
    assert String.contains?(capture_io(fn ->
      IO.inspect(conn.private.plug_route)
    end), "Kitto.Endpoints.Widget")
  end

  test "GET /events forwards to the Event endpoint" do
    conn = conn(:get, "/events")

    spawn fn ->
      receive do
      after
        1 -> send conn.owner, {:misc, :close}
      end
    end

    conn = Kitto.Router.call(conn, @opts)

    assert conn.state == :chunked
    assert String.contains?(capture_io(fn ->
      IO.inspect(conn.private.plug_route)
    end), "Kitto.Endpoints.Event")
  end
end
