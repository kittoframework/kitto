defmodule Kitto.Hook.RouterTest do
  use ExUnit.Case
  use Plug.Test

  import Mock
  import Kitto.TestHelper, only: [wait_for: 1, mock_broadcast: 2]

  alias Kitto.Hook.Router
  alias Kitto.Hook
  alias Kitto.Runner

  @opts Router.init([])

  test "POST /:hook_id responds with 404 when no hook found" do
    conn = conn(:post, "/invalid", Poison.encode!(%{elixir: "is awesome!"}))
    |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end


  test "POST /:hook_id responds with 204 status" do
    conn = conn(:post, "/valid", Poison.encode!(%{elixir: "is awesome!"}))
    |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 204
  end

  test "POST /:hook_id looks up hook in registry" do
    topic = :hook_text
    body = %{text: "Hello from Kitto"}
    conn = conn(:post, "/valid", "{}")

    with_mock Kitto.Notifier, [broadcast!: mock_broadcast(topic, body)] do
      conn |> Router.call(@opts)

      assert_receive :ok
    end
  end
end
