defmodule Kitto.Hook.DSL do
  @moduledoc """
  A DSL to define hooks to populate the widgets with data.
  """

  alias Kitto.Hook
  alias Kitto.Notifier

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Kitto.Hook.DSL
      import Kitto.Notifier, only: [broadcast!: 2]
    end
  end

  defmacro hook(name, contents \\ []) do
    block = Macro.prewalk contents[:do], fn
      {:broadcast!, meta, args = [_]} -> {:broadcast!, meta, [name] ++ args}
      ast_node -> ast_node
    end

    quote do
      Hook.register binding()[:runner_server],
                    unquote(name),
                    (__ENV__ |> Map.take([:file, :line])),
                    fn -> unquote(block) end
    end
  end
end
