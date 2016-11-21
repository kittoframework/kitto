defmodule Kitto.RouterTest do
  use ExUnit.Case
  use Plug.Test

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

  @tag :pending
  test "GET /dashboards forwards to dashboards router" do
  end
end
