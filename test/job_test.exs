defmodule Kitto.JobTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "#start calls the given job after the given interval" do
    pid = self
    job = fn (_) -> send pid, :ok end
    interval = 100

    spawn(Kitto.Job, :new, [interval, job])

    :timer.sleep(interval + 10)
    assert_received :ok
  end

  test "#start does not call the given job before interval" do
    pid = self
    job = fn (_) -> send pid, :ok end
    interval = 100

    spawn(Kitto.Job, :new, [interval, job])

    refute_received :ok
  end

  test "#start call jobs multiple times (n times interval)" do
    pid = self
    job = fn (_) -> send pid, :ok end
    interval = 100
    times = 3

    spawn(Kitto.Job, :new, [interval, job])

    :timer.sleep(interval * times + 10)
    {:messages, mesg} = :erlang.process_info(pid, :messages)

    assert Enum.count(mesg) == times
  end
end
