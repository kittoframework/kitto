defmodule Kitto.Hook do
  @moduledoc """
  Contains functions to run hooks based on their specified options.
  """

  alias Kitto.Hook.Registry

  def register(server, name, options, definition, hook) do
    Registry.register server, {:hook, %{name: to_string(name), hook: hook, options: options, definition: definition}}
  end
end
