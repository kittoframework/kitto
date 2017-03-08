defmodule Kitto.Runner do
  @moduledoc """
  Module responsible for loading job files
  """

  use GenServer

  require Logger
  alias Kitto.Job.{Validator, Workspace}

  @max_restarts Application.get_env :kitto, :job_max_restarts, 300

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
    spawn fn -> load_hooks(server) end

    {:ok, %{opts: opts, jobs: [], hooks: [], supervisor: nil}}
  end

  @doc """
  Updates the list of jobs to be run with the provided one
  """
  def register(server, {:job, job}), do: GenServer.call(server, {:register_job, job})
  def register(server, {:hook, hook}), do: GenServer.call(server, {:register_hook, hook})

  @doc """
  Reloads all jobs defined in the given file
  """
  def reload_job(server, file) do
    GenServer.cast(server, {:reload_job, file})
  end

  @doc """
  Stops all jobs defined in the given file
  """
  def stop_job(server, file) do
    GenServer.cast(server, {:stop_job, file})
  end

  @doc """
  Returns all the registered jobs
  """
  def jobs(server) do
    GenServer.call(server, {:jobs})
  end

  @doc """
  Returns all the registered hooks
  """
  def hooks(server) do
    GenServer.call(server, {:hooks})
  end

  @doc """
  Returns the directory where the job scripts are located
  """
  def jobs_dir, do: dir Application.get_env(:kitto, :jobs_dir, "jobs")

  @doc """
  Returns the directory where the hook scripts are located
  """
  def hooks_dir, do: dir Application.get_env(:kitto, :hooks_dir, "hooks")

  ### Callbacks

  def handle_call({:jobs}, _from, state), do: {:reply, state.jobs, state}

  def handle_call({:hooks}, _from, state), do: {:reply, state.hooks, state}

  def handle_call({:register_job, job}, _from, state) do
    {:reply, job, %{state | jobs: state.jobs ++ [job]}}
  end

  def handle_call({:register_hook, hook}, _from, state) do
    {:reply, hook, %{state | hooks: state.hooks ++ [hook]}}
  end

  @doc false
  def handle_cast({:jobs_loaded}, state) do
    supervisor_opts = %{name: state.opts[:supervisor_name] || :runner_supervisor,
                        jobs: state.jobs}

   {:ok, supervisor} = start_supervisor(supervisor_opts)

   {:noreply, %{state | supervisor: supervisor}}
  end

  def handle_cast({:hooks_loaded}, state) do
    # Use this method to handle anything that needs to be done after all hooks
    # are loaded into Kitto
    {:noreply, state}
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
    Logger.info "Stoppping jobs in file: #{file}"

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

  defp load_job(pid, file), do: load_file(pid, file, "Job")

  defp load_hook(pid, file), do: load_file(pid, file, "Hook")

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

  defp load_hooks(pid) do
    hook_files() |> Enum.each(&(load_hook(pid, &1)))

    GenServer.cast pid, {:hooks_loaded}
  end

  def load_file(pid, file, type) do
    case file |> Validator.valid? do
      true -> file |> Workspace.load_file(pid)
      false -> Logger.warn "#{type}: #{file} contains syntax error(s) and will not be loaded"
    end
  end

  defp job_files, do: jobs_dir() |> files

  defp hook_files, do: hooks_dir() |> files

  defp files(dir), do: Path.wildcard(Path.join(dir, "/**/*.{ex,exs}"))

  defp dir(path), do: Path.join(Kitto.root, path)
end
