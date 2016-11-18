defmodule Kitto.Hooks.DSLTest do
  use ExUnit.Case, async: true

  test "hook macro generates a method for the hook" do
    defmodule TestHook do
      use Kitto.Hooks.DSL
      hook :hello, do: "Hello World"
    end

    assert TestHook.hello == "Hello World"
  end

  test "hook macro appends to the registrar" do
    defmodule TestHook do
      use Kitto.Hooks.DSL
      hook :hello, do: "Hello World"
    end

    assert Enum.count(Kitto.Hooks.Server.hooks) == 1
  end
end
