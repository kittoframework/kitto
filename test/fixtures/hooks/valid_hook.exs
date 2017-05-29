use Kitto.Hook.DSL

hook :valid do
  broadcast! :hook_text, %{text: "Hello from Kitto"}
end
