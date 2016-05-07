Kitto.Job.every :second, fn (notifier) ->
  notifier.broadcast! :random, %{value: :random.uniform * 100 |> Float.round}
end
