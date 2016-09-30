Kitto.Job.every :second, fn (notifier) ->
  notifier.broadcast! :random, %{value: :rand.uniform * 100 |> Float.round}
end
