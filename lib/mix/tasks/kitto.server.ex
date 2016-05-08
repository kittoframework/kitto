defmodule Mix.Tasks.Kitto.Server do
  use Mix.Task

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
    Mix.Task.run "run", run_args() ++ args
  end

  defp run_args do
    if iex_running?, do: [], else: ["--no-halt"]
  end

  defp iex_running? do
    Code.ensure_loaded?(IEx) && IEx.started?
  end
end
