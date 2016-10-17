defmodule Kitto.StatsServer do
  @default_stats %{
    times_triggered: 0,
    times_completed: 0,
    failures: 0,
    avg_time_took: 0.0,
    total_running_time: 0.0
  }

  def start_link do
    Agent.start_link(fn -> %{} end, name: :stats_server)
  end

  def measure(name, job) do
    name |> initialize_stats
    name |> update_trigger_count
    name |> measure_func(job)
  end

  def stats do
    server |> Agent.get(&(&1))
  end

  defp initialize_stats(name) do
    server |> Agent.update(fn (stats) ->
      Map.merge(stats, %{name => Map.get(stats, name, @default_stats)})
    end)
  end

  defp update_trigger_count(name) do
    server |> Agent.update(fn (stats) ->
      new_stats = stats[name]

      stats |> Map.merge(%{name => %{new_stats |
        times_triggered: new_stats[:times_triggered] + 1}})
    end)
  end

  defp measure_func(name, job) do
    run = timed_call(job)

    server |> Agent.update(fn (stats) ->
      new_stats = stats[name]

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

      stats |> Map.merge(%{name => new_stats})
    end)

    if (elem(run, 0) == :error), do: raise(elem(run, 1))
  end

  defp timed_call(f) do
    try do
      {:ok, ((:timer.tc(f) |> elem(0)) / 1_000_000)}
    rescue
      e -> {:error, e}
    end
  end

  defp server, do: Process.whereis(:stats_server)
end
