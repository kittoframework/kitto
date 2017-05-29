defmodule Kitto.StatsServerTest do
  use ExUnit.Case

  alias Kitto.StatsServer

  defmodule BackoffMock do
    @behaviour Kitto.Backoff

    def succeed(_), do: {:ok, :success}
    def fail(_), do: {:ok, :fail}
    def backoff!(_), do: send self(), {:ok, :backoff}
  end

  setup do
    Application.put_env :kitto, :backoff_module, Kitto.StatsServerTest.BackoffMock
    definition = %{file: "jobs/dummy.exs", line: 1}
    job = %{name: :dummy_job, options: %{}, definition: definition, job: fn -> :ok end}
    {:ok, server} = StatsServer.start_link(name: :stats_server)

    on_exit fn ->
      Application.delete_env :kitto, :backoff_module
      Application.delete_env :kitto, :job_backoff_enabled?
      server |> Process.exit(:normal)
    end

    %{
      successful_job: job,
      failing_job: %{job | job: fn -> raise RuntimeError end},
      server: server
     }
  end

  test "#measure initializes the job stats", %{successful_job: job, server: server} do
    server |> StatsServer.measure(job)

    assert StatsServer.stats(server).dummy_job.times_completed == 1
  end

  test "#measure when a job succeeds increments :times_triggered",
    %{successful_job: job, server: server} do
    server |> StatsServer.measure(job)
    server |> StatsServer.measure(job)

    assert StatsServer.stats(server).dummy_job.times_triggered == 2
  end

  test "#measure when a job fails increments :times_triggered", context do
    context.server |> StatsServer.measure(context.successful_job)
    assert_raise Kitto.Job.Error, fn ->
      context.server |> StatsServer.measure(context.failing_job)
    end

    assert StatsServer.stats(context.server).dummy_job.times_triggered == 2
  end

  test "#measure when a job succeeds increments :times_completed",
    %{successful_job: job, server: server} do
    server |> StatsServer.measure(job)
    server |> StatsServer.measure(job)

    assert StatsServer.stats(server).dummy_job.times_completed == 2
  end

  test "#measure when a job fails does not increment :times_completed", context do
    context.server |> StatsServer.measure(context.successful_job)

    assert_raise Kitto.Job.Error, fn ->
      context.server |> StatsServer.measure(context.failing_job)
    end

    assert StatsServer.stats(context.server).dummy_job.times_completed == 1
  end

  test "#measure when a job succeeds increments :total_running_time", context do
    context.server |> StatsServer.measure(context.successful_job)

    running_time = StatsServer.stats(context.server).dummy_job.total_running_time

    context.server |> StatsServer.measure(context.successful_job)

    assert StatsServer.stats(context.server).dummy_job.total_running_time >= running_time
  end

  test "#measure when a job fails does not increment :total_running_time", context do
    context.server |> StatsServer.measure(context.successful_job)

    expected_running_time = StatsServer.stats(context.server).dummy_job.total_running_time

    assert_raise Kitto.Job.Error, fn ->
      context.server |> StatsServer.measure(context.failing_job)
    end

    actual_running_time = StatsServer.stats(context.server).dummy_job.total_running_time

    assert_in_delta actual_running_time, expected_running_time, 0.1
  end

  test "#measure when a job fails, message contains job definition location", context do
    job = context.failing_job

    assert_raise Kitto.Job.Error, ~r/Defined in: #{job.definition.file}/, fn ->
      context.server |> StatsServer.measure(job)
    end
  end

  test "#measure when a job fails, message contains job name", context do
    job = context.failing_job

    assert_raise Kitto.Job.Error, ~r/Job :#{job.name} failed to run/, fn ->
      context.server |> StatsServer.measure(job)
    end
  end

  test "#measure when a job fails, message contains the original error", context do
    job = context.failing_job

    error = Exception.format_banner(:error, %RuntimeError{}) |> Regex.escape
    assert_raise Kitto.Job.Error,
                 ~r/Error: #{error}/,
                 fn -> context.server |> StatsServer.measure(job) end
  end

  test "#measure when a job fails, message contains the stacktrace", context do
    job = context.failing_job

    assert_raise Kitto.Job.Error,
                 ~r/Stacktrace: .*? anonymous fn/,
                 fn -> context.server |> StatsServer.measure(job) end
  end

  describe "when :job_backoff_enabled? is set to false" do
    setup [:disable_job_backoff]

    test "#measure does not apply backoffs", context do
      context.server |> StatsServer.measure(context.successful_job)

      refute_received {:ok, :backoff}
    end
  end

  describe "when :job_backoff_enabled? is set to true" do
    setup [:enable_job_backoff]

    test "#measure applies backoffs", context do
      context.server |> StatsServer.measure(context.successful_job)

      assert_received {:ok, :backoff}
    end
  end

  describe "when :job_backoff_enabled? is not set" do
    test "#measure applies backoffs", context do
      context.server |> StatsServer.measure(context.successful_job)

      assert_received {:ok, :backoff}
    end
  end

  defp disable_job_backoff(_context) do
    Application.put_env :kitto, :job_backoff_enabled?, false
  end

  defp enable_job_backoff(_context) do
    Application.put_env :kitto, :job_backoff_enabled?, true
  end
end
