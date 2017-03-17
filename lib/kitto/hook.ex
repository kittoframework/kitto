defmodule Kitto.Hook do
  @moduledoc """
  Contains functions to run hooks based on their specified options.
  """

  alias Kitto.Runner

  def register(server, name, options, definition, hook) do
    Runner.register server, {:hook, %{name: to_string(name), hook: hook, options: options, definition: definition}}
  end
end
