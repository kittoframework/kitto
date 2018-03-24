defmodule Mix.Tasks.Kitto.Gen.JobTest do
  use ExUnit.Case, async: false
  import Kitto.FileAssertionHelper

  setup do
    on_exit(fn ->
      File.rm_rf!(Path.join(tmp_path, "my_widget"))
    end)

    Mix.Task.clear()
    :ok
  end

  test "fails when job name not provided" do
    assert_raise Mix.Error, "No job name provided", fn ->
      Mix.Tasks.Kitto.Gen.Job.run([])
    end
  end

  test "creates job" do
    Mix.Tasks.Kitto.Gen.Job.run(["--path", tmp_path, "my_job"])
    assert_file(Path.join(tmp_path, "my_job.exs"))
  end
end
