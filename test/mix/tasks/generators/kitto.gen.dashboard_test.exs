defmodule Mix.Tasks.Kitto.Gen.DashboardTest do
  use ExUnit.Case, async: false
  import Kitto.FileAssertionHelper

  setup do
    on_exit(fn ->
      File.rm_rf!(Path.join(tmp_path(), "my_dash.html.eex"))
    end)

    Mix.Task.clear()
    :ok
  end

  test "fails when dashboard name not provided" do
    assert_raise Mix.Error, "No dashboard name provided", fn ->
      Mix.Tasks.Kitto.Gen.Dashboard.run([])
    end
  end

  test "creates dashboard" do
    Mix.Tasks.Kitto.Gen.Dashboard.run(["--path", tmp_path(), "my_dash"])
    assert_file(Path.join(tmp_path(), "my_dash.html.eex"))
  end
end
