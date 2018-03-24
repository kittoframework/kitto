defmodule Mix.Tasks.Kitto.Gen.Dashboard do
  use Mix.Task
  import Mix.Generator
  import Kitto.Generator

  @shortdoc "Generates a new empty dashboard template"

  @template Path.join(Path.expand("./templates", __DIR__), "dashboard.html.eex")

  @moduledoc """
  Generates a new empty dashboard template

  Usage:

      $ mix kitto.gen.dashboard all_the_data
      # generates `dashboards/all_the_data.html.eex`
  """

  @doc false
  def run(argv) do
    {opts, args, _} = parse_options(argv)

    case List.first(args) do
      nil ->
        Mix.shell().error("""
        Usage:

            mix kitto.gen.dashboard sample
        """)

        Mix.raise("No dashboard name provided")

      dashboard ->
        path = Path.join(opts[:path] || "dashboards", "#{dashboard}.html.eex")
        create_file(path, File.read!(@template))
    end
  end
end
