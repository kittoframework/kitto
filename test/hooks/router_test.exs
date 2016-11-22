defmodule Kitto.Hooks.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Mock
  import Kitto.TestHelper, only: [mock_broadcast: 2]

  @opts Kitto.Hooks.Router.init([])

  setup do
    reset_registrar = fn ->
      Process.whereis(:hook_registrar)
      |> Agent.update(fn (_) -> MapSet.new end)
    end
    reset_registrar.()

    Application.put_env :kitto, :hook_dir, "test/fixtures/hooks"

    Kitto.Hooks.init(:ok)

    on_exit fn ->
      reset_registrar.()
      Application.delete_env :kitto, :hook_dir
    end
  end

  test "it routes to a hook when defined" do
    conn = conn :post, "/hello", ""
    topic = :hello
    body = %{text: "Hello World"}

    with_mock Kitto.Notifier, [broadcast!: mock_broadcast(topic, body)] do
      Kitto.Hooks.Router.call(conn, @opts)

      assert_receive :ok
    end
  end

  test "it passes conn object to hook" do
    body = %{text: "Hello from ExUnit"}
    topic = :hello_with_params
    conn = conn :post, "/hello_with_params", Poison.encode!(body)

    with_mock Kitto.Notifier, [broadcast!: mock_broadcast(topic, body)] do
      Kitto.Hooks.Router.call(conn, @opts)

      assert_receive :ok
    end
  end

  test "it routes to a general hook when none found" do
    topic = :some_hook
    body = %{value: 42}
    conn = conn :post, "/some_hook", Poison.encode!(body)

    with_mock Kitto.Notifier, [broadcast!: mock_broadcast(topic, body)] do
      Kitto.Hooks.Router.call(conn, @opts)

      assert_receive :ok
    end
  end
end
