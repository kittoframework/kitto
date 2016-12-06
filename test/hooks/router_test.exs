defmodule Kitto.Hooks.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Mock
  import Kitto.TestHelper, only: [mock_broadcast: 2]

  alias Kitto.{Registry, Notifier}
  alias Kitto.Hooks.Router

  @opts []

  setup do
    {:ok, registry} = Registry.start_link(name: :test_hook_registry)
    on_exit fn -> Process.exit(registry, :kill) end

    {:ok, registry: registry}
  end

  describe "when hook not defined" do
    test "broadcasts request params", %{registry: registry} do
      topic = "some_hook"
      params = %{value: 42}

      conn = conn(:post, "/some_hook", params)
      |> put_private(:registry, registry)

      with_mock Notifier, [broadcast!: mock_broadcast(topic, params)] do
        Router.call(conn, @opts)

        assert_receive :ok
      end
    end
  end

  describe "when hook defined" do
    test "routes to a hook", %{registry: registry} do
      Code.eval_string """
        use Kitto.DSL, type: :hook
        hook :hello, do: broadcast! %{text: "Hello World"}
      """, [registry_server: registry]

      topic = "hello"
      params = %{text: "Hello World"}

      conn = conn(:get, "/hello", "")
      |> put_private(:registry, registry)

      with_mock Notifier, [broadcast!: mock_broadcast(topic, params)] do
        Router.call(conn, @opts)

        assert_receive :ok
      end
    end

    test "it passes conn object to hook", %{registry: registry} do
      Code.eval_string """
        use Kitto.DSL, type: :hook
        hook :hello, do: broadcast! conn.body_params
      """, [registry_server: registry]

      topic = "hello"
      params = %{text: "Hello from ExUnit"}
      conn = conn(:post, "/hello", params)
      |> put_private(:registry, registry)

      with_mock Notifier, [broadcast!: mock_broadcast(topic, params)] do
        Router.call(conn, @opts)

        assert_receive :ok
      end
    end
  end
end
