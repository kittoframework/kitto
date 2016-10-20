defmodule Kitto.Job.Workspace do
  defdelegate eval_file(file), to: Code, as: :eval_file
end
