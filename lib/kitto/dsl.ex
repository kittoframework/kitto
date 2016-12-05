defmodule Kitto.DSL do
  @moduledoc """
  Kitto's DSL for defining jobs and hooks to populate widgets with data.
  """

  alias Kitto.Notifier

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Notifier, only: [broadcast!: 2]
    end
  end

  @doc """
  Main API to define jobs.

  Jobs can either be defined with a block or a command. When using a block, the
  expression represents data retrieval and any transformations required to
  broadcast events to the widgets. With command, the stdout and exit code of
  the command will be broadcasted to the widgets using the jobs name as the
  data source.

  Data broadcast using commands is in the form `{exit_code: integer, stdout: String.t}`

  ## Examples

      use Kitto.Job.DSL

      job :jenkins, every: :minute do
        jobs = Jenkins.jobs |> Enum.map(fn (%{"job" => job}) -> %{job: job.status} end)

        broadcast! :jenkins, %{jobs: jobs}
      end

      job :twitter, do: Twitter.stream("#elixir", &(broadcast!(:twitter, &1))

      job :echo, every: :minute, command: "echo hello"

      job :kitto_last_commit,
          every: {5, :minutes},
          command: "curl https://api.github.com/repos/kittoframework/kitto/commits\?page\=1\&per_page\=1"


  ## Options
    * `:every` - Sets the interval on which the job will be performed. When it's not
    specified, the job will be called once (suitable for streaming resources).

    * `:first_at` - A timeout after which to perform the job for the first time

    * `:command` - A command to be run on the server which will automatically
    broadcast events using the jobs name.
  """
  defmacro job(name, options, contents \\ []) do
  end

  @doc """
  Main API to define hooks.

  Define a new Webhook like follows:

      # hooks/hello.exs
      use Kitto.Hooks.DSL

      hook :hello, do: broadcast! :hello, %{text: "Hello World"}

  The hook will generate a route at `/hooks/hello` based on the first argument
  of `hook/2`

  Hooks act like routes in `Plug.Route` and come complete with the `conn`
  object for accessing request information.
  """
  defmacro hook(name, do: block) do
  end
end
