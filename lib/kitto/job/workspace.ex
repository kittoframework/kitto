defmodule Kitto.Job.Workspace do
  @moduledoc false

  @spec load_file(String.t(), pid()) :: {any(), any()}
  def load_file(file, server) do
    Code.eval_string(File.read!(file), [runner_server: server], file: file, line: 1)
  end
end
