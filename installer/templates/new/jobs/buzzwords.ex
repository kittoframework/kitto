random = fn -> :rand.uniform * 100 |> Float.round end

Kitto.Job.every 2, :seconds, fn (notifier) ->
  list = ~w[synergy startup catalyst docker microservice container elixir react]
  |> Enum.map(fn (w) -> %{ label: w, value: random.() } end)
  |> Enum.shuffle

  notifier.broadcast! :buzzwords, %{items: list}
end
