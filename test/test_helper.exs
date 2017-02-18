defmodule Kitto.TestHelper do
  def atomify_map(map) do
    for {key, value} <- map, into: %{}, do: {String.to_atom(key), value}
  end

  def wait_for(name, interval \\ 100, timeout \\ 1000) do
    pid = self()
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

Code.require_file(Path.join("support", "file_assertion_helper.exs"), __DIR__)
Code.require_file(Path.join("support", "mix_generator_helper.exs"), __DIR__)

Mix.shell(Mix.Shell.Process)
ExUnit.configure(exclude: [pending: true])
ExUnit.start()
