defmodule Kitto.Job do
  @defaults first_at: nil

  def start_link(interval, job, options \\ @defaults) do
    pid = spawn_link(Kitto.Job, :new, [interval, job, options])

    {:ok, pid}
  end

  def new(job), do: register(job, interval: nil)
  def new(nil, job, _) do
    job.(Kitto.Notifier)

    receive do
    end
  end

  def new(interval, job, options) do
    first_at(options[:first_at], job)

    receive do
    after
      interval ->
        job.(Kitto.Notifier)
        new(interval, job, first_at: false)
    end
  end

  def every(n, :seconds, job), do: register(job, interval: n * 1000)
  def every(n, :minutes, job), do: register(job, interval: n * 1000 * 60)
  def every(n, :hours, job), do: register(job, interval: n * 1000 * 60)

  def every(:second, job), do: every(1, :seconds, job)
  def every(:minute, job), do: every(1, :minutes, job)
  def every(:hour, job), do: every(60, :minutes, job)
  def every(:day, job), do: every(24, :hours, job)

  defp first_at(false, job), do: nil

  defp first_at(t, job) do
    if t, do: :timer.sleep(round(t * 1000))

    job.(Kitto.Notifier)
  end

  defp register(job, options) do
    Kitto.Runner.register(job: job, options: options)
  end
end
