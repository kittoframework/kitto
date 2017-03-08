use Kitto.Hook.DSL

hook :valid do
  broadcast! :text, %{text: "Hello from Kitto"}
end
