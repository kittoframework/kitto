use Kitto.Job.DSL

job :text, every: {4, :seconds} do
  phrases = ["This is your shiny new dashboard", "Built on the Kitto Framework"]

  broadcast! :text, %{text: (phrases |> Enum.shuffle |> Enum.take(1))}
end
