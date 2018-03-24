defmodule Kitto.Runner do
  @moduledoc """
  Module responsible for loading job files
  """

  use GenServer

  require Logger
  alias Kitto.Job.{Validator, Workspace}

  @doc """
  Starts the runner supervision tree
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  @doc false
  def init(opts) do
    server = self()
    spawn fn -> load_jobs(server) end

    {:ok, %{opts: opts, jobs: [], supervisor: nil}}
  end

  @doc """
  Updates the list of jobs to be run with the provided one
  """
  @spec register(pid() | atom(), map()) :: map()
  def register(server, job) do
    GenServer.call(server, {:register, job})
  end

  @doc """
  Reloads all jobs defined in the given file
  """
  @spec register(pid() | atom(), map()) :: :ok
  def reload_job(server, file) do
    GenServer.cast(server, {:reload_job, file})
  end

  @doc """
  Stops all jobs defined in the given file
  """
  @spec stop_job(pid() | atom(), String.t()) :: :ok
  def stop_job(server, file) do
    GenServer.cast(server, {:stop_job, file})
  end

  @doc """
  Returns all the registered jobs
  """
  @spec jobs(pid() | atom()) :: list(map())
  def jobs(server) do
    GenServer.call(server, {:jobs})
  end

  @doc """
  Returns the directory where the job scripts are located
  """
  @spec jobs_dir() :: String.t()
  def jobs_dir, do: Path.join(Kitto.root, Application.get_env(:kitto, :jobs_dir, "jobs"))

  ### Callbacks

  def handle_call({:jobs}, _from, state) do
    {:reply, state.jobs, state}
  end

  def handle_call({:register, job}, _from, state) do
    {:reply, job, %{state | jobs: state.jobs ++ [job]}}
  end

  @doc false
  def handle_cast({:jobs_loaded}, state) do
    supervisor_opts = %{name: state.opts[:supervisor_name] || :runner_supervisor,
                        jobs: state.jobs}

   {:ok, supervisor} = start_supervisor(supervisor_opts)

   {:noreply, %{state | supervisor: supervisor}}
  end

  def handle_cast({:reload_job, file}, state) do
    Logger.info "Reloading job file: #{file}"

    jobs = stop_jobs(state, file)

    server = self()
    spawn fn ->
      load_job(server, file)
      server
      |> jobs
      |> jobs_in_file(file)
      |> Enum.each(&(start_job(state.supervisor, &1)))
    end

    {:noreply, %{state | jobs: jobs}}
  end

  def handle_cast({:stop_job, file}, state) do
    Logger.info "Stopping jobs in file: #{file}"

    {:noreply, %{state | jobs: stop_jobs(state, file)}}
  end

  defp jobs_in_file(jobs, file) do
    jobs |> Enum.filter(fn %{definition: %{file: f}} -> f == file end)
  end

  defp start_supervisor(opts) do
    Kitto.Runner.JobSupervisor.start_link(opts)
  end

  defp start_job(supervisor, job) do
    Kitto.Runner.JobSupervisor.start_job(supervisor, job)
  end

  defp load_job(pid, file) do
    case file |> Validator.valid? do
      true -> file |> Workspace.load_file(pid)
      false -> Logger.warn "Job: #{file} contains syntax error(s) and will not be loaded"
    end
  end

  defp stop_jobs(state, file) do
    state.jobs
    |> jobs_in_file(file)
    |> Enum.reduce(state.jobs, fn (job, jobs) ->
      Supervisor.terminate_child(state.supervisor, job.name)
      Supervisor.delete_child(state.supervisor, job.name)
      jobs |> List.delete(job)
    end)
  end

  defp load_jobs(pid) do
    job_files() |> Enum.each(&(load_job(pid, &1)))

    GenServer.cast pid, {:jobs_loaded}
  end

  defp job_files, do: Path.wildcard(Path.join(jobs_dir(), "/**/*.{ex,exs}"))
end
