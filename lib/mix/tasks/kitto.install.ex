defmodule Mix.Tasks.Kitto.Install do
  use Mix.Task
  @shortdoc "Install community Widget/Job from a Github Gist"
  @supported_languages ["JavaScript", "SCSS", "Markdown", "Elixir"]

  @moduledoc """
  Installs a custom Widget/Job from a Github gist

  ## Command line options

  This task accepts the same command-line arguments as `run`.
  For additional information, refer to the documentation for
  `Mix.Tasks.Run`.
  """
  def run(args) do
    {:ok, _started} = Application.ensure_all_started(:httpoison)
    {opts, _parsed, _} = OptionParser.parse(args, strict: [widget: :string, gist: :string])
    opts_map = Enum.into(opts, %{})
    process(opts_map)
  end

  # Process the install incase we have a gist and widget name
  # It will download the gist files and place them in the right location
  #
  defp process(%{gist: gist, widget: widget}) do
    gist
      |> String.split("/")
      |> build_gist_url
      |> download_gist
      |> Map.get(:files)
      |> Enum.map(&extract_file_properties/1)
      |> Enum.filter(&supported_file_type?/1)
      |> Enum.map(&(determine_file_location(&1, widget)))
      |> Enum.each(&write_file/1)
  end

  defp process(_) do
    Logger.error "Unsupported arguments"
    exit(:shutdown)
  end

  defp write_file(file) do
    Mix.Generator.create_directory(file.path)
    filename = file.path <> file.filename
    Mix.Generator.create_file(filename, file.content)
  end

  # Elixir files we place in the jobs dir
  defp determine_file_location(%{language: "Elixir"} = file, _) do
    Map.put(file, :path, "./jobs/")
  end

  # Other files all go into the widget dir
  defp determine_file_location(file, widget_name) do
    Map.put(file, :path, "./widgets/#{widget_name}/")
  end

  defp supported_file_type?(file) do
    Enum.member?(@supported_languages, file.language)
  end

  def extract_file_properties({_filename, file}), do: file

  defp download_gist(url), do: HTTPoison.get!(url) |> process_response
  defp build_gist_url([_user | gist]), do: 'https://api.github.com/gists/#{gist}'

  defp process_response(%HTTPoison.Response{status_code: 200, body: body}), do: body |> Poison.decode!(keys: :atoms)
  defp process_response(error), do: {:error, error}
end
