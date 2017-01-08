defmodule Kitto.Generator do
  @moduledoc """
  Convenience when building generators for Kitto
  """

  @doc ~S"""
  Parses arguments passed from command line.

  Examples:

      iex> Kitto.Generator.parse_options(["my_widget"])
      {[], ["my_widget"], []}

      iex> Kitto.Generator.parse_options(["-p", "dashboard_path", "my_dashboard"])
      {[path: "dashboard_path"], ["my_dashboard"], []}

      iex> Kitto.Generator.parse_options(["--path", "dash", "my_dashboard"])
      {[path: "dash"], ["my_dashboard"], []}
  """
  def parse_options(argv) do
    OptionParser.parse(argv, aliases: [p: :path])
  end
end
