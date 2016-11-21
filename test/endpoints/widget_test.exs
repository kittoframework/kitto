defmodule Kitto.Endpoints.WidgetTest do
  use ExUnit.Case
  use Plug.Test

  import Mock
  import Kitto.TestHelper, only: [atomify_map: 1, mock_broadcast: 2]

  @opts Kitto.Endpoints.Widget.init([])
  @endpoint Kitto.Endpoints.Widget

  test "GET / responds with 200 OK" do
    conn = conn(:get, "/")
    conn = @endpoint.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "GET / responds with valid JSON" do
    conn = conn(:get, "/")
    conn = Kitto.Endpoints.Widget.call(conn, @opts)

    Poison.decode! conn.resp_body
  end

  test "GET / responds with all cached events" do
    conn = conn(:get, "/")

    Kitto.Notifier.clear_cache
    Kitto.Notifier.cache :technology, %{news: "man made it to mars"}
    Kitto.Notifier.cache :stockmarket, %{trend: "it's going up"}

    conn = @endpoint.call(conn, @opts)

    with parsed_body <- Poison.decode!(conn.resp_body) do
      assert parsed_body |> Map.has_key?("technology")
      assert parsed_body |> Map.has_key?("stockmarket")
    end
  end

  test "GET /:id responds with cached events for the specified key" do
    conn = conn(:get, "/technology")
    cached_event = %{news: "man made it to mars"}
    irrelevant_event = %{message: "nobody cares about this"}

    Kitto.Notifier.clear_cache
    Kitto.Notifier.cache :technology, cached_event
    Kitto.Notifier.cache :irrelevant, irrelevant_event

    conn = @endpoint.call(conn, @opts)
    parsed_body = Poison.decode!(conn.resp_body)

    assert atomify_map(parsed_body) == cached_event
  end

  test "POST /:id responds with 204 No Content" do
    topic = "technology"
    conn = conn(:post, "/#{topic}", Poison.encode!(%{elixir: "is awesome!"}))

    conn = @endpoint.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 204
  end

  test "POST /:id broadcasts the body on the given topic" do
    topic = "technology"
    body = %{elixir: "is awesome!"}
    conn = conn(:post, "/#{topic}", Poison.encode!(%{elixir: "is awesome!"}))

    with_mock Kitto.Notifier, [broadcast!: mock_broadcast(topic, body)] do
      @endpoint.call(conn, @opts)

      assert_receive :ok
    end
  end

  test "with auth token POST /:id grants access when provided" do
    Application.put_env :kitto, :auth_token, "asecret"
    topic = "technology"
    body = %{elixir: "is awesome!"}

    conn = conn(:post, "/#{topic}", Poison.encode!(body))
      |> put_req_header("authentication", "Token asecret")
      |> @endpoint.call(@opts)

    assert conn.state == :sent
    assert conn.status == 204
    Application.delete_env :kitto, :auth_token
  end

  test "with auth token POST /:id denies access when not provided" do
    Application.put_env :kitto, :auth_token, "asecret"
    topic = "technology"
    body = %{elixir: "is awesome!"}

    conn = conn(:post, "/#{topic}", Poison.encode!(body))
      |> @endpoint.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
    Application.delete_env :kitto, :auth_token
  end
end
