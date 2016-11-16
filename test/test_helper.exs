defmodule Kitto.TestHelper do
  def atomify_map(map) do
    for {key, value} <- map, into: %{}, do: {String.to_atom(key), value}
  end
end

ExUnit.configure(exclude: [pending: true])
ExUnit.start()
