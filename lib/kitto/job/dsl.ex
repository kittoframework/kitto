defmodule Kitto.Job.DSL do
  @moduledoc """
  A DSL to define jobs populating the widgets with data.
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Kitto.Job.DSL
      import Kitto.Notifier, only: [broadcast!: 2]
    end
  end

  @doc """
  Main API to define jobs.

  It accepts an expression representing data retrieval and any transformations
  required to broadcast events to the widgets.

  ## Examples

      use Kitto.Job.DSL

      job :jenkins, every: :minute do
        jobs = Jenkins.jobs |> Enum.map(fn (%{"job" => job}) -> %{job: job.status} end)

        broadcast! :jenkins, %{jobs: jobs}
      end

      job :twitter, do: Twitter.stream("#elixir", &(broadcast!(:twitter, &1))

  ## Options
    * `:every` - Sets the interval on which the job will be performed. When it's not
    specified, the job will be called once (suitable for streaming resources).

    * `:first_at` - A timeout after which to perform the job for the first time
  """
  defmacro job(name, options, contents \\ []) do
    quote do
      Kitto.Job.register unquote(name),
                         unquote(options),
                         (__ENV__ |> Map.take([:file, :line])),
                         fn -> unquote(contents[:do]) end
    end
  end
end
