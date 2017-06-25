defmodule Kitto.StatsServer do
  @moduledoc """
  Module responsible for keeping stats about jobs.
  """

  use GenServer

  @server __MODULE__
  @default_stats %{
    times_triggered: 0,
    times_completed: 0,
    failures: 0,
    avg_time_took: 0.0,
    total_running_time: 0.0
  }

  @doc false
  def start_link(opts) do
    GenServer.start_link(@server, opts, name: opts[:name] || @server)
  end

  @doc false
  def init(_), do: {:ok, %{}}

  @doc """
  Executes the given function and keeps stats about it in the provided key
  """
  @spec measure(map()) :: :ok
  def measure(job), do: measure(@server, job)
  def measure(server, job) do
    server |> initialize_stats(job.name)
    server |> update_trigger_count(job.name)
    server |> measure_call(job)
  end

  @doc """
  Returns the current stats
  """
  @spec stats() :: map()
  @spec stats(pid() | atom()) :: map()
  def stats, do: stats(@server)
  def stats(server), do: GenServer.call(server, :stats)

  @doc """
  Resets the current stats
  """
  @spec reset() :: :ok
  @spec reset(pid() | atom()) :: :ok
  def reset, do: reset(@server)
  def reset(server), do: GenServer.cast(server, :reset)

  ### Callbacks

  def handle_call(:stats, _from, state), do: {:reply, state, state}
  def handle_call({:initialize_stats, name}, _from, state) do
    {:reply, name, Map.merge(state, %{name => Map.get(state, name, @default_stats)})}
  end
  def handle_call({:update_trigger_count, name}, _from, state) do
    old_stats = state[name]
    new_stats = %{name => %{old_stats | times_triggered: old_stats[:times_triggered] + 1}}

    {:reply, name, Map.merge(state, new_stats)}
  end

  def handle_cast(:reset, _state), do: {:noreply, %{}}
  def handle_cast({:measure_call, job, run}, state) do
    current_stats = state[job.name]

    new_stats = case run do
      {:ok, time_took} ->
        backoff_module().succeed(job.name)
        times_completed = current_stats[:times_completed] + 1
        total_running_time = current_stats[:total_running_time] + time_took

        %{current_stats |
          times_completed: times_completed,
          total_running_time: total_running_time
        } |> Map.merge(%{avg_time_took: total_running_time / times_completed})
      {:error, _} ->
        backoff_module().fail(job.name)
        %{current_stats | failures: current_stats[:failures] + 1}
    end

    {:noreply, Map.merge(state, %{job.name => new_stats})}
  end

  defp initialize_stats(server, name), do: GenServer.call(server, {:initialize_stats, name})

  defp update_trigger_count(server, name),
    do: GenServer.call(server, {:update_trigger_count, name})
  defp measure_call(server, job) do
    if backoff_enabled?(), do: backoff_module().backoff!(job.name)

    run = timed_call(job.job)

    GenServer.cast(server, {:measure_call, job, run})

    if elem(run, 0) == :error do
      raise Kitto.Job.Error, %{exception: elem(run, 1), job: job}
    end
  end

  defp timed_call(f) do
    try do
      {:ok, ((f |> :timer.tc |> elem(0)) / 1_000_000)}
    rescue
      e -> {:error, e}
    end
  end

  defp backoff_enabled?, do: Application.get_env :kitto, :job_backoff_enabled?, true

  defp backoff_module do
    Application.get_env :kitto, :backoff_module, Kitto.BackoffServer
  end
end
