defmodule Kitto.Hook.RegistryTest do
  use ExUnit.Case, async: false

  alias Kitto.Hook.Registry

  @hooks_dir "test/fixtures/hooks"

  setup do
    {:ok, registry} = Registry.start_link(name: :test_hook_registry)

    {:ok, %{registry: registry}}
  end

  describe ".register/1" do
    test "loads a hook into the registry by name", %{registry: registry} do
      hook = %{name: "my_test_hook"}

      assert {:ok, _} = Registry.register(registry, hook)
      assert (registry |> Registry.hooks |> Map.keys) == ["my_test_hook"]
    end

    test "loads from the hooks directory" do
      Application.put_env(:kitto, :hooks_dir, @hooks_dir)
      {:ok, registry} = Registry.start_link(name: :test_hook_loader_registry)

      assert (registry |> Registry.hooks |> Map.keys) == ["valid"]
    end
  end
end
