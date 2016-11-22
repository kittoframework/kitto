defmodule Kitto.RouterTest do
  use ExUnit.Case
  use Plug.Test

  import ExUnit.CaptureIO
  import Mock
  import Kitto.TestHelper, only: [atomify_map: 1, mock_broadcast: 2]

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

  test """
  GET /dashboards with :default_dashboard left unconfigured redirects to dashboards/sample
  """ do
    conn = conn(:get, "/dashboards")
    Application.delete_env :kitto, :default_dashboard
    conn = Kitto.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 301
    assert (conn |> get_resp_header("location") |> hd) == "/dashboards/sample"
  end

  test """
  GET /dashboards with :default_dashboard configured redirects to the configured dashboard
  """ do
    conn = conn(:get, "/dashboards")

    Application.put_env :kitto, :default_dashboard, "jobs"
    conn = Kitto.Router.call(conn, @opts)
    Application.delete_env :kitto, :default_dashboard

    assert conn.state == :sent
    assert conn.status == 301
    assert (conn |> get_resp_header("location") |> hd) == "/dashboards/jobs"
  end

  test "GET /dashboards/:id when dashboard does not exist responds with 404 Not Found" do
    dashboard = "nonexistant"
    conn = conn(:get, "/dashboards/#{dashboard}")

    conn = Kitto.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "Dashboard \"#{dashboard}\" does not exist"
  end

  test "GET /dashboards/:id when dashboard exists responds with 200 OK" do
    view = "body"
    conn = conn(:get, "/dashboards/sample")

    with_mock Kitto.View, [exists?: fn (_) -> true end, render: fn (_) -> view end] do
      conn = Kitto.Router.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body == view
    end
  end

  test "GET /events responds with 200 OK" do
    conn = conn(:get, "events")

    spawn fn ->
      receive do
      after
        1 -> send conn.owner, {:misc, :close}
      end
    end

    conn = Kitto.Router.call(conn, @opts)
    assert conn.state == :chunked
    assert conn.status == 200
  end

  test "GET /events streams broadcasted messages" do
    Kitto.Notifier.clear_cache
    conn = conn(:get, "events")
    topic = "technology"
    message = "Kitto is awesome!"

    spawn fn ->
      receive do
      after
        1 ->
          send conn.owner, {:broadcast, {topic, message}}
          send conn.owner, {:misc, :close}
      end
    end

    conn = Kitto.Router.call(conn, @opts)
    assert conn.resp_body == "event: #{topic}\ndata: {\"message\": \"#{message}\"}\n\n"
  end

  test """
  GET /events streams does not broadcast messages not included in the provided topics
  """ do
    Kitto.Notifier.clear_cache
    conn = conn(:get, "events?topics=weather")
    topic = "technology"
    message = "Kitto is awesome!"

    spawn fn ->
      receive do
      after
        1 ->
          send conn.owner, {:broadcast, {topic, message}}
          send conn.owner, {:misc, :close}
      end
    end

    conn = Kitto.Router.call(conn, @opts)
    assert conn.resp_body == ""
  end

  test """
  GET /events streams broadcasts only messages included in the provided topics
  """ do
    Kitto.Notifier.clear_cache
    conn = conn(:get, "events?topics=technology")
    events = [
      {:weather, "cloudy with a chance of meatballs"},
      {:technology, "kitto is awesome"}
    ]

    spawn fn ->
      receive do
      after
        1 ->
          send conn.owner, {:broadcast, events |> Enum.at(0)}
          send conn.owner, {:broadcast, events |> Enum.at(1)}
          send conn.owner, {:misc, :close}
      end
    end

    conn = Kitto.Router.call(conn, @opts)
    assert conn.resp_body == """
    event: #{events |> Enum.at(1) |> elem(0)}
    data: {\"message\": \"#{events |> Enum.at(1) |> elem(1)}\"}\n
    """
  end

  @tag :pending
  test "GET /events streams cached events first" do
    Kitto.Notifier.clear_cache
    Kitto.Notifier.cache :technology, %{news: "man made it to mars"}
    conn = conn(:get, "events")
    topic = "technology"
    message = "man made it to mars"

    spawn fn ->
      receive do
      after
        1 ->
          send conn.owner, {:misc, :close}
      end
    end

    conn = Kitto.Router.call(conn, @opts)
    assert conn.resp_body == "event: #{topic}\ndata: {\"message\": \"#{message}\"}\n\n"
  end

  test "GET /widgets responds with 200 OK" do
    conn = conn(:get, "widgets")
    conn = Kitto.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "GET /widgets responds with valid JSON" do
    conn = conn(:get, "widgets")
    conn = Kitto.Router.call(conn, @opts)

    Poison.decode! conn.resp_body
  end

  test "GET /widgets responds with all cached events" do
    conn = conn(:get, "widgets")

    Kitto.Notifier.clear_cache
    Kitto.Notifier.cache :technology, %{news: "man made it to mars"}
    Kitto.Notifier.cache :stockmarket, %{trend: "it's going up"}

    conn = Kitto.Router.call(conn, @opts)

    with parsed_body <- Poison.decode!(conn.resp_body) do
      assert parsed_body |> Map.has_key?("technology")
      assert parsed_body |> Map.has_key?("stockmarket")
    end
  end

  test "GET /widgets/:id responds with cached events for the specified key" do
    conn = conn(:get, "widgets/technology")
    cached_event = %{news: "man made it to mars"}
    irrelevant_event = %{message: "nobody cares about this"}

    Kitto.Notifier.clear_cache
    Kitto.Notifier.cache :technology, cached_event
    Kitto.Notifier.cache :irrelevant, irrelevant_event

    conn = Kitto.Router.call(conn, @opts)
    parsed_body = Poison.decode!(conn.resp_body)

    assert atomify_map(parsed_body) == cached_event
  end

  test "POST /widgets/:id responds with 204 No Content" do
    topic = "technology"
    conn = conn(:post, "widgets/#{topic}", Poison.encode!(%{elixir: "is awesome!"}))

    conn = Kitto.Router.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 204
  end

  test "POST /widgets/:id broadcasts the body on the given topic" do
    topic = "technology"
    body = %{elixir: "is awesome!"}
    conn = conn(:post, "widgets/#{topic}", Poison.encode!(%{elixir: "is awesome!"}))

    with_mock Kitto.Notifier, [broadcast!: mock_broadcast(topic, body)] do
      Kitto.Router.call(conn, @opts)

      assert_receive :ok
    end
  end

  test "with auth token POST /widgets/:id grants access when provided" do
    Application.put_env :kitto, :auth_token, "asecret"
    topic = "technology"
    body = %{elixir: "is awesome!"}

    conn = conn(:post, "widgets/#{topic}", Poison.encode!(body))
      |> put_req_header("authentication", "Token asecret")
      |> Kitto.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 204
    Application.delete_env :kitto, :auth_token
  end

  test "with auth token POST /widgets/:id denies access when not provided" do
    Application.put_env :kitto, :auth_token, "asecret"
    topic = "technology"
    body = %{elixir: "is awesome!"}

    conn = conn(:post, "widgets/#{topic}", Poison.encode!(body))
      |> Kitto.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
    Application.delete_env :kitto, :auth_token
  end

  test "POST /dashboards/:id requires authentication" do
    Application.put_env :kitto, :auth_token, "asecret"
    conn = conn(:post, "dashboards/sample", "")
      |> Kitto.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
    Application.delete_env :kitto, :auth_token
  end

  test "POST /dashboards/:id reloads single dashboard" do
    dashboard = "sample"
    body = %{command: "reload"}
    conn = conn(:post, "dashboards/#{dashboard}", Poison.encode!(body))

    mock = mock_broadcast "_kitto", Map.put(body, :dashboard, dashboard)

    with_mock Kitto.Notifier, [broadcast!: mock] do
      Kitto.Router.call(conn, @opts)

      assert_receive :ok
    end
  end

  test "POST /dashboards requires authentication" do
    Application.put_env :kitto, :auth_token, "asecret"
    conn = conn(:post, "dashboards", "")
      |> Kitto.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
    Application.delete_env :kitto, :auth_token
  end

  test "POST /dashboards reloads all dashboards" do
    body = %{command: "reload"}
    conn = conn(:post, "dashboards", Poison.encode!(body))

    mock = mock_broadcast "_kitto", Map.put(body, :dashboard, "*")

    with_mock Kitto.Notifier, [broadcast!: mock] do
      Kitto.Router.call(conn, @opts)

      assert_receive :ok
    end
  end

  test "POST /dashboards with dashboard in body reloads that dashboard" do
    body = %{command: "reload", dashboard: "sample"}
    conn = conn(:post, "dashboards", Poison.encode!(body))

    mock = mock_broadcast "_kitto", Map.put(body, :dashboard, "sample")

    with_mock Kitto.Notifier, [broadcast!: mock] do
      Kitto.Router.call(conn, @opts)

      assert_receive :ok
    end
  end

  test "GET /hooks forwards to hook router" do
    conn = conn(:get, "hooks")
    |> Kitto.Router.call(@opts)

    assert conn.state == :sent
    assert String.contains?(capture_io(fn ->
      IO.inspect(conn.private.plug_route)
    end), "Kitto.Hooks.Router")
  end
end
