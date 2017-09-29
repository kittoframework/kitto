defmodule Kitto.Job do
  @moduledoc """
  Contains functions to run jobs based on their specified options.
  """

  alias Kitto.Runner

  @doc """
  Starts a job process
  """
  def start_link(job) do
    pid = spawn_link(Kitto.Job, :new, [job])
    pid |> Process.register(job.name)

    {:ok, pid}
  end

  @doc """
  Registers a job to be started as a process by the runner supervisor
  """
  @spec register(pid(), atom(), keyword(), map(), (() -> any())) :: map()
  def register(server, name, options, definition, job) do
    import Kitto.Time

    opts = [interval: options[:every] |> mseconds,
            first_at: options[:first_at] |> mseconds]

    Runner.register server, %{name: name, job: job, options: opts, definition: definition}
  end

  @doc """
  Runs the job based on the given options
  """
  @spec new(map()) :: no_return()
  def new(job) do
    case job.options[:interval] do
      nil -> once(job)
      _   -> with_interval(job)
    end
  end

  defp with_interval(job) do
    first_at(job[:options][:first_at], job)

    receive do
    after
      job.options[:interval] ->
        run job
        with_interval(put_in(job.options[:first_at], false))
    end
  end

  defp run(job), do: Kitto.StatsServer.measure(job)

  defp once(job) do
    run job

    receive do
    end
  end

  defp first_at(false, _job), do: nil
  defp first_at(t, job) do
    if t, do: :timer.sleep(t)

    run job
  end
end
