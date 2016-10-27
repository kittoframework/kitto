defmodule Kitto.Job.Workspace do
  @moduledoc false

  defdelegate eval_file(file), to: Code, as: :eval_file
end
