defmodule Kitto.Hook do
  @moduledoc """
  Contains functions to run hooks based on their specified options.
  """

  alias Kitto.Hook.Registry

  def register(server, name, definition, hook) do
    Registry.register server, %{name: to_string(name), hook: hook, definition: definition}
  end
end
