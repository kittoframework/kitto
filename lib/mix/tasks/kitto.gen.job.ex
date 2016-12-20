defmodule Mix.Tasks.Kitto.Gen.Job do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Generates a new job"

  @template Path.join Path.expand("./templates", __DIR__), "job.exs.eex"

  @moduledoc """
  Generates a new empty job

  Usage:

      $ mix kitto.gen.job some_job
      # generates `jobs/some_job.exs`
  """

  def run(argv) do
    case List.first(argv) do
      nil ->
        IO.puts """
        No job name provided.

        Usage:

            mix kitto.gen.job text
        """
        exit :no_job
      job ->
        create_file Path.join("jobs", "#{job}.exs"), EEx.eval_file(@template, [name: job])
    end
  end
end
