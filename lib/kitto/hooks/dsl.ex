defmodule Kitto.Hooks.DSL do
  @moduledoc """
  DSL for building Webhook handlers. Define a new Webhook like follows:

      # hooks/hello.exs
      use Kitto.Hooks.DSL

      hook :hello, do: broadcast! :hello, %{text: "Hello World"}

  The hook will generate a route at `/hooks/hello` based on the first argument
  of `hook/2`

  Hooks act like routes in `Plug.Route` and come complete with the `conn`
  object for accessing request information.
  """

  alias Kitto.Hooks

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Kitto.Hooks.DSL
      import Kitto.Notifier, only: [broadcast!: 2]
      import Plug.Conn
    end
  end

  @doc """
  The hook macro lets you register hooks. Hooks are implemented as follows:

      hook :hello do
        # Handle data from the request with the `conn` object.
        # Broadcast events to widgets with `broadcast!/2`
      end
  """
  defmacro hook(name, do: block) do
    quote do
      # Append the hook to the list of hooks
      Hooks.register unquote(name), fn(var!(conn)) ->
        _ = var!(conn)
        unquote(block)
      end
    end
  end
end
