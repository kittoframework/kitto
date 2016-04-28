defmodule Kitto.Job do
  def new(interval, job) do
    receive do
    after
      interval ->
        job.(Kitto.Notifier)
    end

    new(interval, job)
  end

  def every(n, :seconds, job), do: start(n * 1000, job)
  def every(n, :minutes, job), do: start(n * 1000 *  60, job)
  def every(n, :hours, job), do: start(n * 1000 * 60 * 60, job)

  def every(:second, job), do: every(1, :seconds, job)
  def every(:minute, job), do: every(1, :minutes, job)
  def every(:hour, job), do: every(60, :minutes, job)
  def every(:day, job), do: every(24, :hours, job)

  defp start(interval, job), do: spawn(Kitto.Job, :new, [interval, job])
end
