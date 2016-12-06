defmodule Kitto.JobTest do
  use ExUnit.Case, async: true

  test "#new calls the given job after the given interval" do
    pid = self
    job = fn -> send pid, :ok end
    interval = 100

    spawn(Kitto.Job, :new, [%{name: :dummy_job,
                              job: job,
                              options: %{interval: interval}}])

    :timer.sleep(interval + 10)
    assert_received :ok
  end

  test "#new does not call the given job before interval" do
    pid = self
    job = fn -> send pid, :ok end
    interval = 100

    spawn(Kitto.Job, :new, [%{name: :dummy_job,
                              job: job,
                              options: %{interval: interval}}])

    refute_received :ok
  end

  test "#new, with first_at option, calls job after first_at seconds" do
    pid = self
    job = fn -> send pid, :ok end
    first_at = 100

    spawn(Kitto.Job, :new, [%{name: :dummy_job,
                              job: job,
                              options: %{first_at: first_at}}])

    :timer.sleep(first_at + 10)

    assert_received :ok
  end

  test "#new, with first_at option, does not call job before first_at" do
    pid = self
    job = fn -> send pid, :ok end
    first_at = 100

    spawn(Kitto.Job, :new, [%{name: :dummy_job,
                              job: job,
                              options: %{first_at: first_at}}])

    refute_received :ok
  end

  test "#new, with first_at unspecified, calls job immediately" do
    pid = self
    job = fn -> send pid, :ok end

    spawn(Kitto.Job, :new, [%{name: :dummy_job,
                              job: job,
                              options: %{}}])

    :timer.sleep(10)

    assert_received :ok
  end

  @tag :pending
  test "#new, calls jobs multiple times" do
    pid = self
    job = fn -> send pid, :ok end
    interval = 100
    times = 3

    spawn(Kitto.Job, :new, [%{name: :dummy_job,
                              job: job,
                              options: %{first_at: false, interval: interval}}])

    :timer.sleep(interval * times + 10)
    {:messages, mesg} = :erlang.process_info(pid, :messages)

    assert Enum.count(mesg) == times
  end
end
