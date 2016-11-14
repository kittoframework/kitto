defmodule Kitto.PlugAuthenticationTest do
  use ExUnit.Case
  use Plug.Test

  @opts Kitto.Plugs.Authentication.init([])

  # NOTE: On tests that test whether the request is granted, the assertion is a little bit awkward.
  # The test specifies that what's expected is that the connection should not be touched by the
  # plug. Only when a request is denied should the plug stop the connection.

  test "grants access when no auth_token set" do
    conn = conn(:post, "/widgets")
    assert Kitto.Plugs.Authentication.call(conn, @opts) == conn
  end

  test "when auth token set only effect POST /widgets/:id" do
    Application.put_env :kitto, :auth_token, "asecret"
    conn = conn(:post, "/dashboard")
    assert Kitto.Plugs.Authentication.call(conn, @opts) == conn
    Application.delete_env :kitto, :auth_token
  end

  test "when auth token set without authorization header denies access" do
    Application.put_env :kitto, :auth_token, "asecret"
    conn = conn(:post, "/widgets") |> Kitto.Plugs.Authentication.call(@opts)
    assert conn.status == 401
    assert conn.state == :sent
    Application.delete_env :kitto, :auth_token
  end

  test "when auth token set with authorization header grants access" do
    Application.put_env :kitto, :auth_token, "asecret"
    conn = conn(:post, "/widgets")
      |> put_req_header("authentication", "Token asecret")

    # See note on L#8 for explanation of how this test works.
    assert Kitto.Plugs.Authentication.call(conn, @opts) == conn
    Application.delete_env :kitto, :auth_token
  end

end
