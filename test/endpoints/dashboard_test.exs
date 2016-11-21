defmodule Kitto.Endpoints.DashboardTest do
  use ExUnit.Case
  use Plug.Test

  import Mock
  import Kitto.TestHelper, only: [mock_broadcast: 2]

  @opts Kitto.Endpoints.Dashboard.init([])
  @endpoint Kitto.Endpoints.Dashboard

  test """
  GET /dashboards with :default_dashboard left unconfigured redirects to dashboards/sample
  """ do
    conn = conn(:get, "/")
    Application.delete_env :kitto, :default_dashboard
    conn = @endpoint.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 301
    assert (conn |> get_resp_header("location") |> hd) == "/dashboards/sample"
  end

  test """
  GET /dashboards with :default_dashboard configured redirects to the configured dashboard
  """ do
    conn = conn(:get, "/")

    Application.put_env :kitto, :default_dashboard, "jobs"
    conn = @endpoint.call(conn, @opts)
    Application.delete_env :kitto, :default_dashboard

    assert conn.state == :sent
    assert conn.status == 301
    assert (conn |> get_resp_header("location") |> hd) == "/dashboards/jobs"
  end

  test "GET /dashboards/:id when dashboard does not exist responds with 404 Not Found" do
    dashboard = "nonexistant"
    conn = conn(:get, "/#{dashboard}")

    conn = @endpoint.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "Dashboard \"#{dashboard}\" does not exist"
  end

  test "GET /dashboards/:id when dashboard exists responds with 200 OK" do
    view = "body"
    conn = conn(:get, "/sample")

    with_mock Kitto.View, [exists?: fn (_) -> true end, render: fn (_) -> view end] do
      conn = @endpoint.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body == view
    end
  end

  test "POST /dashboards/:id requires authentication" do
    Application.put_env :kitto, :auth_token, "asecret"
    conn = conn(:post, "/sample", "")
      |> @endpoint.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
    Application.delete_env :kitto, :auth_token
  end

  test "POST /dashboards/:id reloads single dashboard" do
    dashboard = "sample"
    body = %{command: "reload"}
    conn = conn(:post, "/#{dashboard}", Poison.encode!(body))

    mock = mock_broadcast "_kitto", Map.put(body, :dashboard, dashboard)

    with_mock Kitto.Notifier, [broadcast!: mock] do
      @endpoint.call(conn, @opts)

      assert_receive :ok
    end
  end

  test "POST /dashboards requires authentication" do
    Application.put_env :kitto, :auth_token, "asecret"
    conn = conn(:post, "/", "")
      |> @endpoint.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
    Application.delete_env :kitto, :auth_token
  end

  test "POST /dashboards reloads all dashboards" do
    body = %{command: "reload"}
    conn = conn(:post, "/", Poison.encode!(body))

    mock = mock_broadcast "_kitto", Map.put(body, :dashboard, "*")

    with_mock Kitto.Notifier, [broadcast!: mock] do
      @endpoint.call(conn, @opts)

      assert_receive :ok
    end
  end

  test "POST /dashboards with dashboard in body reloads that dashboard" do
    body = %{command: "reload", dashboard: "sample"}
    conn = conn(:post, "/", Poison.encode!(body))

    mock = mock_broadcast "_kitto", Map.put(body, :dashboard, "sample")

    with_mock Kitto.Notifier, [broadcast!: mock] do
      @endpoint.call(conn, @opts)

      assert_receive :ok
    end
  end
end
