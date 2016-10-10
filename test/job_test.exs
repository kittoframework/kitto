defmodule Kitto.JobTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "#start calls the given job after the given interval" do
    pid = self
    job = fn (_) -> send pid, :ok end
    interval = 100

    spawn(Kitto.Job, :new, [interval, job, %{}])

    :timer.sleep(interval + 10)
    assert_received :ok
  end

  test "#start does not call the given job before interval" do
    pid = self
    job = fn (_) -> send pid, :ok end
    interval = 100

    spawn(Kitto.Job, :new, [interval, job, %{}])

    refute_received :ok
  end

  test "#start, with first_at option provided, initially calls job after first_at seconds" do
    pid = self
    job = fn (_) -> send pid, :ok end
    first_at = 0.01

    spawn(Kitto.Job, :new, [2000, job, %{first_at: first_at}])

    :timer.sleep(round(first_at * 1000) + 10)

    assert_received :ok
  end

  test "#start, with first_at option provided, does not call job before first_at" do
    pid = self
    job = fn (_) -> send pid, :ok end
    first_at = 0.01

    spawn(Kitto.Job, :new, [2000, job, %{first_at: first_at}])

    refute_received :ok
  end

  test "#start, with first_at unspecified, calls job immediately" do
    pid = self
    job = fn (_) -> send pid, :ok end

    spawn(Kitto.Job, :new, [2000, job, %{}])

    :timer.sleep(10)

    assert_received :ok
  end

  test "#start, calls jobs multiple times" do
    pid = self
    job = fn (_) -> send pid, :ok end
    interval = 100
    times = 3

    spawn(Kitto.Job, :new, [interval, job, %{first_at: false}])

    :timer.sleep(interval * times + 10)
    {:messages, mesg} = :erlang.process_info(pid, :messages)

    assert Enum.count(mesg) == times
  end
end
