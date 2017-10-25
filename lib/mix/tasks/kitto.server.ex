defmodule Mix.Tasks.Kitto.Server do
  use Mix.Task
  require Logger

  @watchers webpack: [bin: "./node_modules/.bin/webpack-dev-server",
                      opts: ["--watch", "--progress", "--colors"]]

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
    if Kitto.watch_assets?(), do: spawn(&start_watcher/0)

    Mix.Task.run "run", run_args() ++ args
  end

  defp start_watcher do
    import Kitto, only: [asset_server_host: 0, asset_server_port: 0]

    validate_watcher()

    Logger.info "Starting assets watcher at: #{asset_server_host()}:#{asset_server_port()}"

    System.cmd watcher_bin(),
               watcher()[:opts],
               env: [{"KITTO_ASSETS_HOST", asset_server_host()},
                     {"KITTO_ASSETS_PORT", "#{Kitto.asset_server_port}"}]
  end

  defp validate_watcher do
    unless watcher_exists?() do
      Logger.error "Could not start watcher because #{watcher_bin()} could not " <>
                   "be found. Your dashboard server is running, but assets won't " <>
                   "be compiled."

      exit(:shutdown)
    end
  end

  defp watcher_exists?, do: File.exists? watcher_bin()

  defp watcher, do: Application.get_env(:kitto, :watcher, @watchers[:webpack])
  defp watcher_bin, do: watcher()[:bin] |> Path.expand

  defp run_args, do: if iex_running?(), do: [], else: ["--no-halt"]
  defp iex_running?, do: Code.ensure_loaded?(IEx) && IEx.started?
end
