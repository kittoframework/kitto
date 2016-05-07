Kitto.Job.every 4, :seconds, fn (notifier) ->
  phrases = ["This is your shiny new dashboard", "Built on the Kitto Framework"]

  with text <- (phrases |> Enum.shuffle |> Enum.take(1)) do
    notifier.broadcast! :text, %{text: text}
  end
end
