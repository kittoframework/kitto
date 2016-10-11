defmodule Mix.Tasks.Kitto.Server do
  use Mix.Task
  require Logger

  @watchers webpack: [bin: "./node_modules/.bin/webpack-dev-server",
                      opts: ["--stdin", "--progress"]]

  @shortdoc "Starts applications and their servers"

  @moduledoc """
  Starts the application

  ## Command line options

  This task accepts the same command-line arguments as `run`.
  For additional information, refer to the documentation for
  `Mix.Tasks.Run`.

  The `--no-halt` flag is automatically added.
  """
  def run(args) do
    if Mix.env == :dev && watch_assets?, do: spawn_link(&start_watcher/0)

    Mix.Task.run "run", run_args() ++ args
  end

  defp start_watcher do
    validate_watcher
    System.cmd watcher_bin, watcher[:opts]
  end

  defp validate_watcher do
    unless watcher_exists? do
      Logger.error "Could not start watcher because #{watcher_bin} could not" <>
                   "be found. Your dashboard server is running, but assets won't" <>
                   "be compiled."

      exit(:shutdown)
    end
  end

  defp watch_assets?, do: Application.get_env :kitto, :watch_assets?, true
  defp watcher_exists?, do: File.exists? watcher_bin

  defp watcher, do: Application.get_env(:kitto, :watcher, @watchers[:webpack])
  defp watcher_bin, do: watcher[:bin] |> Path.expand

  defp run_args, do: if iex_running?, do: [], else: ["--no-halt"]
  defp iex_running?, do: Code.ensure_loaded?(IEx) && IEx.started?
end
