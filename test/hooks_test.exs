defmodule Kitto.HooksTest do
  use ExUnit.Case, async: true

  # setup do
  #   reset_registrar = fn ->
  #     Process.whereis(:hook_registrar)
  #     |> Agent.update(fn (_) -> MapSet.new end)
  #   end
  #   reset_registrar.()
  #
  #   Application.put_env :kitto, :hook_dir, "test/fixtures/hooks"
  #   on_exit fn ->
  #     Application.delete_env :kitto, :hook_dir
  #     reset_registrar.()
  #   end
  # end
  #
  # test "loads directory of hook files" do
  #   Kitto.Hooks.init(:ok)
  #   assert Kitto.Hooks.hooks[:hello] != nil
  # end

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
