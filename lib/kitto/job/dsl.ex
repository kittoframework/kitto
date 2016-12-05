defmodule Kitto.Job.DSL do
  @moduledoc """
  A DSL to define jobs populating the widgets with data.
  """

  alias Kitto.Job
  alias Kitto.Notifier

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Kitto.Job.DSL
      import Kitto.Notifier, only: [broadcast!: 2]
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
    if options[:command] do
      _job(:shell, name, options)
    else
      _job(:elixir, name, options, contents)
    end
  end

  defp _job(:elixir, name, options, contents) do
    block = Macro.prewalk (options[:do] || contents[:do]), fn
      {:broadcast!, meta, args = [_]} -> {:broadcast!, meta, [name] ++ args}
      ast_node -> ast_node
    end

    quote do
      Job.register binding[:runner_server],
                   unquote(name),
                   unquote(options |> Keyword.delete(:do)),
                   (__ENV__ |> Map.take([:file, :line])),
                   fn -> unquote(block) end
    end
  end

  defp _job(:shell, name, options) do
    quote do
      command = unquote(options)[:command]
      block = fn ->
        [sh | arguments] = command |> String.split
        {stdout, exit_code} = System.cmd(sh, arguments)

        Notifier.broadcast!(unquote(name), %{stdout: stdout, exit_code: exit_code})
      end

      Job.register binding[:runner_server],
                   unquote(name),
                   unquote(options),
                   (__ENV__ |> Map.take([:file, :line])),
                   block
    end
  end
end
