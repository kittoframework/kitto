defmodule Kitto.Hooks.DSL do
  defmacro __using__(_opts) do
    quote do
      import Kitto.Hooks.DSL
      import Kitto.Notifier, only: [broadcast!: 2]
    end
  end

  defmacro hook(name, do: block) do
    quote do
      # Append the hook to the list of hooks
      def unquote(name)(), do: unquote(block)
      Kitto.Hooks.Server.register(unquote(name), unquote(block))
    end
  end
end
