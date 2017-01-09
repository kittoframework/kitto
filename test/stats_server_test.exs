defmodule Kitto.StatsServerTest do
  use ExUnit.Case

  alias Kitto.StatsServer

  setup do
    definition = %{file: "jobs/dummy.exs", line: 1}
    job = %{name: :dummy_job, options: %{}, definition: definition, job: fn -> :ok end}

    %{
      successful_job: job,
      failing_job: %{job | job: fn -> raise RuntimeError end},
      reset: fn -> StatsServer.reset end
     }
  end

  test "#measure initializes the job stats", %{successful_job: job, reset: reset} do
    reset.()
    StatsServer.measure(job)

    assert StatsServer.stats.dummy_job.times_completed == 1
  end

  test "#measure when a job succeeds increments :times_triggered",
    %{successful_job: job, reset: reset} do
    reset.()
    StatsServer.measure(job)
    StatsServer.measure(job)

    assert StatsServer.stats.dummy_job.times_triggered == 2
  end

  test "#measure when a job fails increments :times_triggered", context do
    context.reset.()

    StatsServer.measure(context.successful_job)
    assert_raise Kitto.Job.Error, fn ->
      StatsServer.measure(context.failing_job)
    end

    assert StatsServer.stats.dummy_job.times_triggered == 2
  end

  test "#measure when a job succeeds increments :times_completed",
    %{successful_job: job, reset: reset} do
    reset.()
    StatsServer.measure(job)
    StatsServer.measure(job)

    assert StatsServer.stats.dummy_job.times_completed == 2
  end

  test "#measure when a job fails does not increment :times_completed", context do
    context.reset.()

    StatsServer.measure(context.successful_job)

    assert_raise Kitto.Job.Error, fn ->
      StatsServer.measure(context.failing_job)
    end

    assert StatsServer.stats.dummy_job.times_completed == 1
  end

  test "#measure when a job succeeds increments :total_running_time", context do
    StatsServer.measure(context.successful_job)

    running_time = StatsServer.stats.dummy_job.total_running_time

    StatsServer.measure(context.successful_job)

    assert StatsServer.stats.dummy_job.total_running_time >= running_time
  end

  test "#measure when a job fails does not increment :total_running_time", context do
    StatsServer.measure(context.successful_job)

    expected_running_time = StatsServer.stats.dummy_job.total_running_time

    assert_raise Kitto.Job.Error, fn ->
      StatsServer.measure(context.failing_job)
    end

    actual_running_time = StatsServer.stats.dummy_job.total_running_time

    assert_in_delta actual_running_time, expected_running_time, 0.1
  end

  test "#measure when a job fails, message contains job definition location", context do

    job = context.failing_job

    assert_raise Kitto.Job.Error, ~r/Defined in: #{job.definition.file}/, fn ->
      StatsServer.measure(job)
    end
  end

  test "#measure when a job fails, message contains job name", context do
    job = context.failing_job

    assert_raise Kitto.Job.Error, ~r/Job :#{job.name} failed to run/, fn ->
      StatsServer.measure(job)
    end
  end

  test "#measure when a job fails, message contains the original error", context do
    job = context.failing_job

    error = Exception.format_banner(:error, %RuntimeError{}) |> Regex.escape
    assert_raise Kitto.Job.Error,
                 ~r/Error: #{error}/,
                 fn -> StatsServer.measure(job) end
  end

  test "#measure when a job fails, message contains the stacktrace", context do
    job = context.failing_job

    assert_raise Kitto.Job.Error,
                 ~r/Stacktrace: .*? anonymous fn/,
                 fn -> StatsServer.measure(job) end
  end
end
