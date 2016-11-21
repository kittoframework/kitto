defmodule Kitto.TestHelper do
  def atomify_map(map) do
    for {key, value} <- map, into: %{}, do: {String.to_atom(key), value}
  end

  def mock_broadcast(expected_topic, expected_body) do
    fn (topic, body) ->
      if topic == expected_topic && atomify_map(body) == expected_body do
        send self, :ok
      else
        send self, :error
      end
    end
  end
end

ExUnit.configure(exclude: [pending: true])
ExUnit.start()
