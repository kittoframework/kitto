defmodule Kitto.Runner do
  use Supervisor
  alias Kitto.Job.Workspace

  @max_restarts Application.get_env :kitto, :job_max_restarts, 300

  @doc """
  Starts the runner supervision tree
  """
  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: :runner_sup)
  end

  def init(:ok) do
    Agent.start_link(fn -> [] end, name: :job_registrar)

    load_jobs

    children = jobs |> Enum.map(&(worker(Kitto.Job, [&1], id: make_ref)))

    supervise(children, strategy: :one_for_one, max_restarts: @max_restarts)
  end

  @doc """
  Updates the list of jobs to be run with the provided one
  """
  def register(job) do
    runner |> Agent.update(fn (jobs) ->
      jobs ++ [job]
    end)
  end

  @doc """
  Returns the list of registered jobs
  """
  def jobs, do: runner |> Agent.get(&(&1))

  defp load_jobs, do: job_files |> Enum.each(&Workspace.eval_file/1)

  defp job_files do
    Path.wildcard Path.join(System.cwd, "jobs/**/*.{ex,exs}")
  end

  defp runner, do: Process.whereis(:job_registrar)
end
