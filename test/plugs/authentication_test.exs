defmodule Kitto.PlugAuthenticationTest do
  use ExUnit.Case
  use Plug.Test

  @opts Kitto.Plugs.Authentication.init([])

  # NOTE: On tests that test whether the request is granted, the assertion is
  # a little bit awkward. The test specifies that what's expected is that the
  # connection should not be touched by the plug. Only when a request is
  # denied should the plug stop the connection.
  test "grants access when authenticated private param is not set" do
    conn = conn(:post, "/widgets")

    assert Kitto.Plugs.Authentication.call(conn, @opts) == conn
  end

  test "grants access when authenticated private param set to false" do
    conn = conn(:post, "/widgets") |> put_private(:authenticated, false)

    assert Kitto.Plugs.Authentication.call(conn, @opts) == conn
  end

  test "grants access when no auth_token set" do
    conn = conn(:post, "/widgets") |> put_private(:authenticated, true)

    assert Kitto.Plugs.Authentication.call(conn, @opts) == conn
  end

  test "grants access when auth token set without authenticated private param" do
    Application.put_env(:kitto, :auth_token, "asecret")
    conn = conn(:post, "/dashboard")

    assert Kitto.Plugs.Authentication.call(conn, @opts) == conn
    Application.delete_env(:kitto, :auth_token)
  end

  test """
  denies access when auth token and authenticated private param set without
  authorization header provided
  """ do
    Application.put_env(:kitto, :auth_token, "asecret")

    conn =
      conn(:post, "/widgets")
      |> put_private(:authenticated, true)
      |> Kitto.Plugs.Authentication.call(@opts)

    assert conn.status == 401
    assert conn.state == :sent
    Application.delete_env(:kitto, :auth_token)
  end

  test """
  grants access when auth token and authenticated private param set with
  authorization header provided
  """ do
    Application.put_env(:kitto, :auth_token, "asecret")

    conn =
      conn(:post, "/widgets")
      |> put_private(:authenticated, true)
      |> put_req_header("authentication", "Token asecret")

    assert Kitto.Plugs.Authentication.call(conn, @opts) == conn
    Application.delete_env(:kitto, :auth_token)
  end
end
