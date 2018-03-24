defmodule Kitto.Job.ValidatorTest do
  use ExUnit.Case, async: true

  @jobs_dir Path.join(~w(test fixtures jobs))

  setup do
    %{
      valid_job: Path.join(@jobs_dir, "valid_job.exs"),
      invalid_job: Path.join(@jobs_dir, "invalid_job.exs")
    }
  end

  test """
       #valid? returns true when the given file does not contain syntax errors
       """,
       %{valid_job: job} do
    assert Kitto.Job.Validator.valid?(job) == true
  end

  test """
       #valid? returns false when the given file contains syntax errors
       """,
       %{invalid_job: job} do
    assert Kitto.Job.Validator.valid?(job) == false
  end
end
