defmodule Mix.Tasks.Kitto.Gen.JobTest do
  use ExUnit.Case, async: false
  import Kitto.MixGeneratorHelper

  setup do
    Mix.Task.clear
    :ok
  end

  test "fails when job name not provided" do
    assert_raise Mix.Error, "No job name provided", fn ->
      Mix.Tasks.Kitto.Gen.Job.run([])
    end
  end

  test "creates job" do
    assert_creates_file "jobs/my_job.exs", fn() -> Mix.Tasks.Kitto.Gen.Job.run(["my_job"]) end
    assert_creates_file ~r/my_job.exs/, fn() -> Mix.Tasks.Kitto.Gen.Job.run(["my_job"]) end
  end
end
