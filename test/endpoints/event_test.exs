defmodule Kitto.Endpoints.EventTest do
  use ExUnit.Case
  use Plug.Test

  @opts Kitto.Endpoints.Event.init([])
  @endpoint Kitto.Endpoints.Event

  test "GET /events responds with 200 OK" do
    conn = conn(:get, "/")

    spawn fn ->
      receive do
      after
        1 -> send conn.owner, {:misc, :close}
      end
    end

    conn = @endpoint.call(conn, @opts)
    assert conn.state == :chunked
    assert conn.status == 200
  end

  test "GET /events streams broadcasted messages" do
    Kitto.Notifier.clear_cache
    conn = conn(:get, "/")
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

    conn = @endpoint.call(conn, @opts)
    assert conn.resp_body == "event: #{topic}\ndata: {\"message\": \"#{message}\"}\n\n"
  end

  @tag :pending
  test "GET /events streams cached events first" do
    Kitto.Notifier.clear_cache
    Kitto.Notifier.cache :technology, %{news: "man made it to mars"}
    conn = conn(:get, "/")
    topic = "technology"
    message = "man made it to mars"

    spawn fn ->
      receive do
      after
        1 ->
          send conn.owner, {:misc, :close}
      end
    end

    conn = @endpoint.call(conn, @opts)
    assert conn.resp_body == "event: #{topic}\ndata: {\"message\": \"#{message}\"}\n\n"
  end
end
