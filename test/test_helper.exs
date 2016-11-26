defmodule Kitto.TestHelper do
  import ExUnit.Assertions

  def atomify_map(map) do
    for {key, value} <- map, into: %{}, do: {String.to_atom(key), value}
  end
end

Mix.shell(Mix.Shell.Process)
ExUnit.configure(exclude: [pending: true])
ExUnit.start()
