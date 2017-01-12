use Kitto.Job.DSL

job :job_failures, every: :second do
  stats = Kitto.StatsServer.stats

  failures = stats
  |> Enum.map(fn ({name, m}) -> %{label: name, value: m[:failures]} end)
  |> Enum.sort(fn (a, b) -> a[:value] > b[:value] end)
  |> Enum.take(15)

  broadcast! %{items: failures}
end

job :job_avg_time, every: {500, :milliseconds} do
  stats = Kitto.StatsServer.stats

  metrics = stats
  |> Enum.map(fn ({name, m}) ->
    %{label: name, value: m[:avg_time_took] |> Float.round(3) }
  end)
  |> Enum.sort(fn (a, b) -> a[:value] > b[:value] end)
  |> Enum.take(15)

  broadcast! %{items: metrics}
end

job :jobs_running, every: {200, :milliseconds} do
  stats = Kitto.StatsServer.stats
  |> Enum.filter(fn ({_name, m}) ->
    (m[:times_completed] + m[:failures]) < m[:times_triggered]
  end)
  |> length

  broadcast! %{value: stats}
end

job :footprint, every: :second do
  mem = :erlang.memory[:processes_used] / 1024 / 1024 |> Float.round(3)

  broadcast! :processes_count, %{value: length(:erlang.processes)}
  broadcast! :memory_usage, %{value: mem}
end

job :uptime, every: :second do
  hours = ((:erlang.statistics(:wall_clock) |> elem(0)) / 1000 / 60.0 / 60.0)
  |> Float.round(3)

  broadcast! %{value: hours}
end
