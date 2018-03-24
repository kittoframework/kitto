defmodule Mix.Tasks.Kitto.Gen.WidgetTest do
  use ExUnit.Case, async: false
  import Kitto.FileAssertionHelper

  setup do
    runner = fn ->
      Mix.Tasks.Kitto.Gen.Widget.run(["--path", tmp_path(), "my_widget"])
    end

    on_exit(fn ->
      File.rm_rf!(Path.join(tmp_path(), "my_widget"))
    end)

    Mix.Task.clear()
    {:ok, [runner: runner]}
  end

  test "fails when widget name not provided" do
    assert_raise Mix.Error, "No widget name provided", fn ->
      Mix.Tasks.Kitto.Gen.Widget.run([])
    end
  end

  test "creates widget", %{runner: runner} do
    runner.()
    assert_file(Path.join(tmp_path(), "my_widget/my_widget.js"))
    assert_file(Path.join(tmp_path(), "my_widget/my_widget.scss"))
  end
end
