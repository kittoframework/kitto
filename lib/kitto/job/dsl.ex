defmodule Kitto.Job.DSL do
  defmacro __using__(_opts) do
    quote do
      import Kitto.Job.DSL
      import Kitto.Notifier, only: [broadcast!: 2]
    end
  end

  defmacro job(name, options, contents \\ []) do
    quote do
      Kitto.Job.register unquote(name),
                         unquote(options),
                         (__ENV__ |> Map.take([:file, :line])),
                         fn -> unquote(contents[:do]) end
    end
  end
end
