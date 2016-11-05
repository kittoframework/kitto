defmodule Kitto.Job.Workspace do
  @moduledoc false

  defdelegate load_file(file), to: Code, as: :load_file
end
