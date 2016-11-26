use Kitto.Job.DSL

job :valid, every: :second do
  broadcast! :text, %{text: "Hello from Kitto"}
end
