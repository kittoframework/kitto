defmodule Kitto.RunnerTest do
  use ExUnit.Case

  require Logger

  import ExUnit.CaptureLog
  import Kitto.TestHelper, only: [wait_for: 1]

  alias Kitto.Runner

  @jobs_dir "test/fixtures/jobs"
  @valid_job Path.join(@jobs_dir, "valid_job.exs") |> Path.absname
  @updated_job Path.join(@jobs_dir, "updated_valid_job.file") |> Path.absname
  @hooks_dir "test/fixtures/hooks"

  setup do
    Application.put_env :kitto, :jobs_dir, @jobs_dir
    Application.put_env :kitto, :hooks_dir, @hooks_dir
    valid_job = File.read! @valid_job

    on_exit fn ->
      Application.delete_env :kitto, :jobs_dir
      File.write! @valid_job, valid_job
    end
  end

  describe "jobs" do
    test "#jobs_dir returns the jobs directory" do
      assert Runner.jobs_dir == Path.join(System.cwd, @jobs_dir)
    end

    test "#register appends a job to the list of jobs" do
      Application.delete_env :kitto, :jobs_dir

      {:ok, runner} = Runner.start_link(name: :job_runner)
      job = %{name: :dummy}

      runner |> Runner.register({:job, job})
      assert runner |> Runner.jobs == [job]
    end

    test "loads only valid jobs" do
      capture_log(fn ->
        {:ok, runner} = Runner.start_link(name: :job_runner,
                                          supervisor_name: :runner_sup)

        wait_for(:runner_sup)

        jobs = runner |> Runner.jobs

        assert Enum.map(jobs, &(&1.name)) == [:valid]
      end)
    end

    test "logs warning for jobs with syntax errors" do
      assert capture_log(fn ->
        {:ok, _runner} = Runner.start_link(name: :job_runner,
                                           supervisor_name: :runner_sup)

        wait_for(:runner_sup)
      end) =~ "syntax error(s) and will not be loaded"
    end

    test "#reload stops and starts jobs defined in the reloaded file" do
      capture_log fn ->
        {:ok, runner} = Runner.start_link(name: :job_runner, supervisor_name: :runner_sup)

        supervisor = wait_for(:runner_sup)
        job_before = Process.whereis(:valid)
        Process.monitor(job_before)

        File.write!(@valid_job, File.read!(@updated_job))

        runner |> Runner.reload_job(@valid_job)

        receive do
          {:DOWN, _, _, ^job_before, _} ->
            job_after = wait_for(:updated_valid)
            [{child_name, _, _, _}] = supervisor |> Supervisor.which_children

            refute job_before == job_after
            assert child_name == :updated_valid
        end
      end
    end

    test "#stop_job stops all jobs defined in the reloaded file" do
      capture_log fn ->
        {:ok, runner} = Runner.start_link(name: :job_runner, supervisor_name: :runner_sup)

        wait_for(:runner_sup)
        job = Process.whereis(:valid)
        Process.monitor(job)

        runner |> Runner.stop_job(@valid_job)

        receive do
          {:DOWN, _, _, ^job, _} -> :ok
        end
      end
    end
  end

  describe "hooks" do
    test "#hooks_dir returns the hooks directory" do
      assert Runner.hooks_dir == Path.join(System.cwd, @hooks_dir)
    end

    test "#register appends a hook to the list of hooks" do
      Application.delete_env :kitto, :hooks_dir

      {:ok, runner} = Runner.start_link(name: :hook_runner)
      hook = %{name: :dummy}

      runner |> Runner.register({:hook, hook})
      assert runner |> Runner.hooks == [hook]
    end

    test "loads only valid hooks" do
      capture_log(fn ->
        {:ok, runner} = Runner.start_link(name: :hook_runner,
                                          supervisor_name: :runner_sup)
        wait_for(:runner_sup)

        hooks = runner |> Runner.hooks

        assert Enum.map(hooks, &(&1.name)) == [:valid]
      end)
    end
  end
end
