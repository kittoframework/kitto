defmodule Kitto.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, registry} = Kitto.Registry.start_link
    {:ok, registry: registry}
  end

  test "creates source types" do
    type = "foo"
    assert Kitto.Registry.lookup(type) == :error

    Kitto.Registry.create(type)
    assert {:ok, source_type} = Kitto.Registry.lookup(type)

    assert Process.alive? source_type
  end
end
