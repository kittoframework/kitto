defmodule Kitto.CodeReloader do
  @moduledoc """
  Handles reloading of code in development
  """

  use GenServer

  alias Kitto.Runner

  @doc """
  Starts the code reloader server
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  @doc false
  def init(opts) do
    if reload_code?() do
      :fs.start_link(:default_fs)
      :fs.subscribe(:default_fs)
    end

    {:ok, %{opts: opts}}
  end

  @doc """
  Returns true when the code reloader is set to start
  See: https://github.com/kittoframework/kitto/wiki/Code-Reloading
  """
  def reload_code?, do: Application.get_env(:kitto, :reload_code?, true)

  ### Callbacks

  # Linux inotify
  def handle_info({_pid, {:fs, :file_event}, {path, event}}, state)
      when event in [[:modified, :closed], [:created]],
      do: reload(path, state)

  def handle_info({_pid, {:fs, :file_event}, {path, [:deleted]}}, state), do: stop(path, state)

  # Mac fsevent
  def handle_info({_pid, {:fs, :file_event}, {path, [_, _, :modified, _]}}, state) do
    reload(path, state)
  end

  def handle_info({_pid, {:fs, :file_event}, {path, [_, :modified]}}, state) do
    reload(path, state)
  end

  def handle_info(_other, state) do
    {:noreply, state}
  end

  defp stop(path, state) do
    with file <- path |> to_string do
      if job?(file), do: Runner.stop_job(state.opts[:server], file)
    end

    {:noreply, state}
  end

  defp reload(path, state) do
    with file <- path |> to_string do
      cond do
        file |> job? ->
          Runner.reload_job(state.opts[:server], file)

        file |> lib? ->
          Mix.Tasks.Compile.Elixir.run(["--ignore-module-conflict"])

        # File not watched.
        true ->
          :noop
      end
    end

    {:noreply, state}
  end

  defp jobs_rexp, do: ~r/#{Kitto.Runner.jobs_dir()}.+.*exs?$/
  defp lib_rexp, do: ~r/#{Kitto.root()}\/lib.+.*ex$/

  defp lib?(path), do: String.match?(path, lib_rexp())
  defp job?(path), do: path |> String.match?(jobs_rexp())
end
