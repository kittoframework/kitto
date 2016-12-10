use Kitto.Hooks.DSL

hook :hello, do: broadcast! :hello, %{text: "Hello World"}
