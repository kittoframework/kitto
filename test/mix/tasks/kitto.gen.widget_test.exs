defmodule Mix.Tasks.Kitto.Gen.WidgetTest do
  use ExUnit.Case, async: false
  import Kitto.MixGeneratorHelper

  setup do
    runner = fn -> Mix.Tasks.Kitto.Gen.Widget.run(["my_widget"]) end
    Mix.Task.clear
    {:ok, [runner: runner]}
  end

  test "fails when widget name not provided" do
    assert_raise Mix.Error, "No widget name provided", fn ->
      Mix.Tasks.Kitto.Gen.Widget.run([])
    end
  end

  test "creates widget js", %{runner: runner} do
    assert_creates_file ~r/my_widget\.js/, runner
  end

  test "creates widget scss", %{runner: runner} do
    assert_creates_file ~r/my_widget\.scss/, runner
  end
end
