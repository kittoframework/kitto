defmodule Kitto.HooksTest do
  use ExUnit.Case, async: true

  setup do
    block = fn ->
      IO.puts "Hello World"
    end
    {:ok, %{block: block}}
  end

  test "can register a hook", %{block: block} do
    assert Kitto.Hooks.lookup(:foo) == :error
    assert Kitto.Hooks.register(:foo, block) == :ok
    assert {:ok, _block} = Kitto.Hooks.lookup(:foo)
  end
end
