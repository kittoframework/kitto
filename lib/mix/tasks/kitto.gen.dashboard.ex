defmodule Mix.Tasks.Kitto.Gen.Dashboard do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Generates a new empty dashboard template"

  @template Path.join Path.expand("./templates", __DIR__), "dashboard.html.eex"

  @moduledoc """
  Generates a new empty dashboard template

  Usage:

      $ mix kitto.gen.dashboard all_the_data
      # generates `dashboards/all_the_data.html.eex`
  """

  def run(argv) do
    case List.first(argv) do
      nil ->
        IO.puts """
        No dashboard name provided.
        Usage:

            mix kitto.gen.dashboard sample
        """
        exit :no_dashboard
      dashboard ->
        create_file Path.join("dashboards", "#{dashboard}.html.eex"), File.read!(@template)
    end
  end
end
