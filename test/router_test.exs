defmodule Kitto.RouterTest do
  use ExUnit.Case
  use Plug.Test

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

  test "GET dashboards/:id when dashboard does not exist responds with 404 Not Found" do
    dashboard = "nonexistant"
    conn = conn(:get, "/dashboards/#{dashboard}")

    conn = Kitto.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "Dashboard \"#{dashboard}\" does not exist"
  end

  test "GET dashboards/:id when dashboard exists responds with 200 OK" do
    view = "body"
    conn = conn(:get, "/dashboards/sample")

    with_mock Kitto.View, [exists?: fn (_) -> true end, render: fn (_) -> view end, ] do
      conn = Kitto.Router.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body == view
    end
  end

  test "GET events responds with 200 OK" do
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

  test "GET events streams broadcasted messages" do
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

  @tag :pending
  test "GET events streams cached events first" do
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

  test "post widgets/:id responds with 204 No Content" do
    topic = "technology"
    conn = conn(:post, "widgets/#{topic}", Poison.encode!(%{elixir: "is awesome!"}))

    conn = Kitto.Router.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 204
  end

  test "post widgets/:id broadcasts the body on the given topic" do
    topic = "technology"
    body = %{elixir: "is awesome!"}
    conn = conn(:post, "widgets/#{topic}", Poison.encode!(%{elixir: "is awesome!"}))

    mock = fn (t, b) ->
      stringified_body = for {key, val} <- b, into: %{}, do: {String.to_atom(key), val}

      if (t == topic && stringified_body == body) do
        send self, :ok
      end
    end

    with_mock Kitto.Notifier, [broadcast!: mock] do
      Kitto.Router.call(conn, @opts)

      assert_receive :ok
    end
  end
end
