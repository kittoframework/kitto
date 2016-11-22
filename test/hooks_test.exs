defmodule Kitto.HooksTest do
  use ExUnit.Case, async: true

  setup do
    reset_registrar = fn ->
      Process.whereis(:hook_registrar)
      |> Agent.update(fn (_) -> MapSet.new end)
    end
    reset_registrar.()

    Application.put_env :kitto, :hook_dir, "test/fixtures/hooks"
    on_exit fn ->
      Application.delete_env :kitto, :hook_dir
      reset_registrar.()
    end
  end

  test "loads directory of hook files" do
    Kitto.Hooks.init(:ok)
    assert Enum.count(Kitto.Hooks.hooks) == 2
    assert Kitto.Hooks.hooks[:hello] != nil
  end
end
