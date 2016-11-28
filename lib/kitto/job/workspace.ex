defmodule Kitto.Job.Workspace do
  @moduledoc false

  def load_file(file, server) do
    Code.eval_string(File.read!(file), [runner_server: server], file: file, line: 1)
  end
end
