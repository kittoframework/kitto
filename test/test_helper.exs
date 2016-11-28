defmodule Kitto.TestHelper do
  def atomify_map(map) do
    for {key, value} <- map, into: %{} do
      {if(is_atom(key), do: key, else: String.to_atom(key)), value}
    end
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

  def wait_for(name, interval \\ 100, timeout \\ 1000) do
    pid = self
    spawn_link(fn -> await_process(pid, name, interval) end)

    receive do
      {:started, awaited} -> awaited
    after
      timeout -> exit({:wait_failed, "could not start process: #{name}"})
    end
  end

  defp await_process(pid, name, interval) do
    receive do
    after
      interval ->
        awaited = Process.whereis(name)

        if awaited && Process.alive?(awaited) do
          send pid, {:started, awaited}
          exit(:normal)
        else
          await_process(pid, name, interval)
        end
    end
  end
end

ExUnit.configure(exclude: [pending: true])
ExUnit.start()
