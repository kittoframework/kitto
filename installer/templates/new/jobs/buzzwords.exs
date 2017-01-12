use Kitto.Job.DSL

job :buzzwords, every: :second do
  random = fn -> :rand.uniform * 100 |> Float.round end

  list = ~w[synergy startup catalyst docker microservice container elixir react]
          |> Enum.map(fn (w) -> %{ label: w, value: random.() } end)
          |> Enum.shuffle

  broadcast! %{items: list}
end
