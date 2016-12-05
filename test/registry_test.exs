defmodule Kitto.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, registry} = Kitto.Registry.start_link
    {:ok, registry: registry}
  end

  test "creates source types", %{registry: registry} do
    assert Kitto.Registry.lookup(registry, "jobs") == :error

    Kitto.Registry.create(registry, "jobs")
    assert {:ok, source_type} = Kitto.Registry.lookup(registry, "jobs")

    assert Process.alive? source_type
  end
end
