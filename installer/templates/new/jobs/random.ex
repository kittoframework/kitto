use Kitto.Job.DSL

job :random, every: :second do
  broadcast! :random, %{value: :rand.uniform * 100 |> Float.round}
end
