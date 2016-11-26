defmodule Kitto.RunnerTest do
  use ExUnit.Case

  require Logger

  import ExUnit.CaptureLog

  alias Kitto.Runner

  setup do
    Application.put_env :kitto, :jobs_dir, "test/fixtures/jobs"

    on_exit fn ->
      Application.delete_env :kitto, :jobs_dir
    end
  end

  test "loads only valid jobs" do
    capture_log(fn ->
      Runner.start_link(name: :runner, registrar_name: :registrar)

      jobs = Process.whereis(:registrar) |> Runner.jobs

      assert Enum.map(jobs, &(&1.name)) == [:valid]
    end)
  end

  test "logs warning for jobs with syntax errors" do
    assert capture_log(fn ->
      Runner.start_link(name: :runner, registrar_name: :registrar)
    end) =~ "syntax error(s) and will not be loaded"
  end
end
