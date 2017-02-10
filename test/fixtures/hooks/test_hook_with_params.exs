use Kitto.Hooks.DSL

hook :hello_with_params do
  {:ok, body, _} = read_body conn
  broadcast! :hello_with_params, body |> Poison.decode!
end
