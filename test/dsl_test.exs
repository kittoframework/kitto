defmodule Kitto.DSLTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, registry} = Kitto.Registry.start_link(name: :test_registry)
    on_exit fn -> Process.exit(registry, :kill) end

    {:ok, registry: registry}
  end

  describe "jobs with blocks" do
    test "can define a job", %{registry: registry} do
      pre_size = Enum.count Kitto.Registry.jobs(registry)
      Code.eval_string """
        use Kitto.DSL
        job :hello_world, every: {5, :seconds}, do: IO.puts("Hello")
      """, [registry_server: registry]

      assert Enum.count(Kitto.Registry.jobs(registry)) == pre_size + 1
    end
  end

  describe "jobs with commands" do
  end

  describe "hooks" do
    test "can define a hook", %{registry: registry} do
      pre_size = Enum.count Kitto.Registry.hooks(registry)
      Code.eval_string """
        use Kitto.DSL, type: :hook
        hook :hello_world, do: IO.puts("Hello")
      """, [registry_server: registry]

      assert Enum.count(Kitto.Registry.hooks(registry)) == pre_size + 1
    end
  end
end
