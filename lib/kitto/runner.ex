defmodule Kitto.Runner do
  @moduledoc """
  Module responsible for loading job files
  """

  use Supervisor
  require Logger
  alias Kitto.Job.{Validator, Workspace}

  @max_restarts Application.get_env :kitto, :job_max_restarts, 300

  @doc """
  Starts the runner supervision tree
  """
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: opts[:name])
  end

  def init(opts) do
    {:ok, registrar} = start_job_registrar(opts[:registrar_name] || :job_registrar)

    load_jobs

    children = registrar |> jobs |> Enum.map(&(worker(Kitto.Job, [&1], id: make_ref)))

    supervise(children, strategy: :one_for_one, max_restarts: @max_restarts)
  end

  @doc """
  Updates the list of jobs to be run with the provided one
  """
  def register(job), do: registrar_pid |> Agent.update(&(&1 ++ [job]))

  @doc """
  Returns the list of registered jobs
  """
  def jobs(pid), do: pid |> Agent.get(&(&1))

  defp start_job_registrar(name) do
    Process.put :registrar_name, name

    Agent.start_link(fn -> [] end, name: name)
  end

  defp load_jobs do
    job_files
    |> Enum.map(&{&1, Validator.valid?(&1)})
    |> Enum.each(fn
      ({job, true}) -> job |> Workspace.load_file
      ({job, false}) ->
        Logger.warn "Job: #{job} contains syntax error(s) and will not be loaded"
    end)
  end

  defp job_files, do: Path.wildcard(Path.join(jobs_dir, "/**/*.{ex,exs}"))
  defp jobs_dir, do: Path.join(Kitto.root, Application.get_env(:kitto, :jobs_dir, "jobs"))
  defp registrar_pid, do: :registrar_name |> Process.get |> Process.whereis
end
