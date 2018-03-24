defmodule Kitto.Runner.JobSupervisor do
  @moduledoc """
  Module responsible of job processes supervision
  """

  use Supervisor

  @max_restarts Application.get_env(:kitto, :job_max_restarts, 300)

  @doc """
  Starts the job supervision tree
  """
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: opts[:name])
  end

  @doc false
  def init(opts) do
    children = opts.jobs |> Enum.map(&child_spec/1)

    supervise(children, strategy: :one_for_one, max_restarts: @max_restarts)
  end

  @doc """
  Dynamically attaches a child process for the given job
  """
  def start_job(pid, job) do
    Supervisor.start_child(pid, child_spec(job))
  end

  defp child_spec(job) do
    worker(Kitto.Job, [job], id: job.name)
  end
end
