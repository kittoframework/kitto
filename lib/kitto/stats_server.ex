defmodule Kitto.StatsServer do
  @moduledoc """
  Module responsible for keeping stats about jobs.
  """

  import Agent, only: [start_link: 2, update: 2, get: 2]

  @default_stats %{
    times_triggered: 0,
    times_completed: 0,
    failures: 0,
    avg_time_took: 0.0,
    total_running_time: 0.0
  }

  @doc false
  def start_link, do: start_link(fn -> %{} end, name: :stats_server)

  @doc """
  Executes the given function and keeps stats about it in the provided key
  """
  def measure(job) do
    job.name |> initialize_stats
    job.name |> update_trigger_count
    job |> measure_call
  end

  @doc """
  Returns the current stats
  """
  def stats, do: server |> get(&(&1))

  defp initialize_stats(name) do
    server |> update(fn (metrics) ->
      Map.merge(metrics, %{name => Map.get(metrics, name, @default_stats)})
    end)
  end

  defp update_trigger_count(name) do
    server |> update(fn (metrics) ->
      new_stats = metrics[name]

      metrics |> Map.merge(%{name => %{new_stats |
        times_triggered: new_stats[:times_triggered] + 1}})
    end)
  end

  defp measure_call(job) do
    run = timed_call(job.job)

    server |> update(fn (metrics) ->
      new_stats = metrics[job.name]

      new_stats = case run do
        {:ok, time_took} ->
          new_times_completed = new_stats[:times_completed] + 1
          new_total_running_time = new_stats[:total_running_time] + time_took

          %{new_stats |
             times_completed: new_times_completed,
             total_running_time: new_total_running_time}
           |> Map.merge(%{avg_time_took: new_total_running_time / new_times_completed})
        {:error, _} -> %{new_stats | failures: new_stats[:failures] + 1}
      end

      metrics |> Map.merge(%{job.name => new_stats})
    end)

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

  defp server, do: Process.whereis(:stats_server)
end
