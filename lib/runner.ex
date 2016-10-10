defmodule Kitto.Runner do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: :runner_sup)
  end

  def init(:ok) do
    Agent.start_link(fn -> [] end, name: :job_registrar)

    load_jobs

    children = jobs |> Enum.map(fn (job) ->
      worker(Kitto.Job, [job[:options][:interval], job[:job]], id: make_ref)
    end)

    supervise(children, strategy: :one_for_one)
  end

  def register(job) do
    runner |> Agent.update(fn (jobs) ->
      jobs ++ [job]
    end)
  end

  def jobs, do: runner |> Agent.get(&(&1))

  defp load_jobs, do: job_files |> Enum.each(&Code.eval_file/1)

  defp job_files do
    Path.wildcard Path.join(System.cwd, "jobs/**/*.{ex,exs}")
  end

  defp runner, do: Process.whereis(:job_registrar)
end
