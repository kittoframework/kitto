defmodule Kitto.CodeReloader do
  @moduledoc """
  Handles reloading of code in development
  """

  use GenServer

  alias Kitto.Runner

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  def init(opts) do
    Application.ensure_all_started(:fs)
    :fs.subscribe

    {:ok, %{opts: opts}}
  end

  ### Callbacks

  def handle_info({_pid, {:fs, :file_event}, {path, [:modified, _]}}, state) do
    with file <- path |> to_string do
      cond do
        file |> job? -> reload(:job, state.opts[:server], file)
        file |> lib? -> Mix.Tasks.Compile.Elixir.run ["--ignore-module-conflict"]
        true -> :noop # File not watched.
      end
    end

    {:noreply, state}
  end

  def handle_info(_other, state) do
    {:noreply, state}
  end

  defp reload(:job, server, file) do
    server |> Process.whereis |> Runner.reload_job(file)
  end

  defp jobs_rexp, do: ~r/#{Kitto.Runner.jobs_dir}.+.*exs?$/
  defp lib_rexp, do: ~r/#{Kitto.root}\/lib.+.*ex$/

  defp lib?(path), do: String.match?(path, lib_rexp)
  defp job?(path), do: path |> String.match?(jobs_rexp)
end
