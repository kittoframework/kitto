defmodule Mix.Tasks.Kitto.Install.Widget do
  use Mix.Task
  require Logger

  @supported_languages [
    "JavaScript",
    "SCSS",
    "Markdown"
  ]
  @shortdoc "Install a custom Widget from a Github gist"

  @moduledoc """
  Installs a custom Widget from a Github gist

  ## Command line options

  This task accepts the same command-line arguments as `run`.
  For additional information, refer to the documentation for
  `Mix.Tasks.Run`.
  """
  def run(args) do
    {:ok, _started} = Application.ensure_all_started(:httpoison)
    {opts, parsed, _} = OptionParser.parse(args, strict: [widget: :string])
    
    widget_path = "./widgets/" <> Keyword.get(opts, :widget)
    gist = List.first(parsed)
      |> String.split("/")
      |> build_gist_url
      |> download_gist
    # Create the folder
    File.mkdir_p!(widget_path)

    # For each of the files in the gist, write them
    gist.files
      |> Enum.filter(&supported_filetypes/1)
      |> Enum.map(fn({_filename, file}) -> file end)
      |> Enum.each(&(write_widget_file(&1, widget_path)))
  end

  defp write_widget_file(file, widget_path) do
    path = "#{widget_path}/#{file.filename}"
    IO.puts("Writing: #{path}")
    File.write!(path, file.content)
  end

  defp supported_filetypes({_filename, file}) do
    Enum.member?(@supported_languages, file.language)
  end

  defp download_gist(url) do
    HTTPoison.get!(url) |> process_response
  end

  defp build_gist_url([_user | gist]) do
    'https://api.github.com/gists/#{gist}'
  end

  defp process_response(%HTTPoison.Response{status_code: 200, body: body}), do: body |> Poison.decode!(keys: :atoms)
  defp process_response(error), do: {:error, error}
end
