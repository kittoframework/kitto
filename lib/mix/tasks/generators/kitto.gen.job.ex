defmodule Mix.Tasks.Kitto.Gen.Job do
  use Mix.Task
  import Mix.Generator
  import Kitto.Generator

  @shortdoc "Generates a new job"

  @template Path.join(Path.expand("./templates", __DIR__), "job.exs.eex")

  @moduledoc """
  Generates a new empty job

  Usage:

      $ mix kitto.gen.job some_job
      # generates `jobs/some_job.exs`
  """

  @doc false
  def run(argv) do
    {opts, args, _} = parse_options(argv)

    case List.first(args) do
      nil ->
        Mix.shell().error("""
        Usage:

            mix kitto.gen.job text
        """)

        Mix.raise("No job name provided")

      job ->
        path = Path.join(opts[:path] || "jobs", "#{job}.exs")
        create_file(path, EEx.eval_file(@template, name: job))
    end
  end
end
