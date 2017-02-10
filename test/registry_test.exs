defmodule Kitto.RegistryTest do
  use ExUnit.Case, async: true

  alias Kitto.Registry

  setup do
    {:ok, registry} = Registry.start_link(name: :test_registry)
    on_exit fn -> Process.exit(registry, :kill) end

    {:ok, registry: registry}
  end

  test "creates source types", %{registry: registry} do
    type = "foo"
    assert Registry.lookup(registry, type) == :error

    Registry.create(registry, type)
    assert {:ok, source_type} = Registry.lookup(registry, type)

    assert Process.alive? source_type
  end

  test "auto-creates the job and hook source types", %{registry: registry} do
    assert {:ok, _jobs} = Registry.lookup(registry, :jobs)
    assert {:ok, _hooks} = Registry.lookup(registry, :hooks)
  end

  describe "Registering jobs" do
    test "can register jobs", %{registry: registry} do
      pre_size = Enum.count Registry.jobs(registry)
      Registry.register(registry, :job, :hello, {%{}, fn() -> true end})

      {_options, block, _context} = Registry.job(registry, :hello)

      assert Enum.count(Registry.jobs(registry)) == pre_size + 1
      assert block.()
    end
  end

  describe "Registering hooks" do
    test "can register hooks", %{registry: registry} do
      pre_size = Enum.count Registry.hooks(registry)
      Registry.register(registry, :hook, :hello, {%{}, fn() -> true end})

      {_options, block, _context} = Registry.hook(registry, :hello)

      assert Enum.count(Registry.hooks(registry)) == pre_size + 1
      assert block.()
    end
  end
end
