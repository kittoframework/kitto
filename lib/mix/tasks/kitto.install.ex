defmodule Mix.Tasks.Kitto.Install do
  use Mix.Task
  @shortdoc "Install community Widget/Job from a Github Gist"

  @github_base_url "https://api.github.com/gists/"
  @supported_languages ["JavaScript", "SCSS", "Markdown", "Elixir"]

  @job_rexp ~r/\.exs$/
  @lib_rexp ~r/\.ex$/

  @moduledoc """
  Installs community Widget/Job from a Github Gist

      mix kitto.install --widget test_widget --gist JanStevens/0209a4a80cee782e5cdbe11a1e9bc393
      mix kitto.install --gist 0209a4a80cee782e5cdbe11a1e9bc393

  ## Options

    * `--widget` - specifies the widget name that will be used as directory name
      in the widgets directory. By default we use the js filename as directory

    * `--gist` - The gist to download from, specified as `Username/Gist` or `Gist`

  """
  def run(args) do
    {:ok, _started} = Application.ensure_all_started(:httpoison)
    {opts, _parsed, _} = OptionParser.parse(args, strict: [widget: :string, gist: :string])
    opts_map = Enum.into(opts, %{})

    process(opts_map)
  end

  defp process(%{gist: gist, widget: widget}) do
    files = gist |> String.split("/")
    |> build_gist_url
    |> download_gist
    |> Map.get(:files)
    |> Enum.map(&extract_file_properties/1)
    |> Enum.filter(&supported_file_type?/1)

    widget_dir = widget || find_widget_filename(files)

    files
    |> Enum.map(&(determine_file_location(&1, widget_dir)))
    |> Enum.each(&write_file/1)
  end

  defp process(%{gist: gist}), do: process(%{gist: gist, widget: nil})

  defp process(_) do
    Mix.shell.error "Unsupported arguments"
  end

  defp write_file(file) do
    Mix.Generator.create_directory(file.path)
    Mix.Generator.create_file(Path.join(file.path, file.filename), file.content)
  end

  defp determine_file_location(_file, widget_name) when is_nil(widget_name) do
    Mix.shell.error "Please specify a widget directory using the --widget flag"
    Mix.raise "Installation failed"
  end

  defp determine_file_location(file = %{language: "Elixir", filename: filename}, _) do
    file |> put_in([:path], (cond do
      Regex.match?(@job_rexp, filename) -> "jobs"
      Regex.match?(@lib_rexp, filename) -> "lib"
      true -> Mix.shell.error "Found Elixir file #{filename} not ending in .ex or exs"
    end))
  end

  # Other files all go into the widgets dir
  defp determine_file_location(file, widget_name) do
    put_in file, [:path], Path.join(["widgets", widget_name])
  end

  defp find_widget_filename(files) do
    files
    |> Enum.filter(&(&1.language == "JavaScript"))
    |> List.first
    |> extract_widget_dir
  end

  defp extract_widget_dir(%{filename: filename}) do
    filename |> String.replace(~r/\.js$/, "")
  end

  defp extract_widget_dir(nil), do: nil

  defp supported_file_type?(file), do: Enum.member?(@supported_languages, file.language)

  defp extract_file_properties({_filename, file}), do: file

  defp download_gist(url), do: url |> HTTPoison.get! |> process_response

  defp build_gist_url([gist_url]), do: @github_base_url <> gist_url
  defp build_gist_url([_ | gist_url]), do: build_gist_url(gist_url)

  defp process_response(%HTTPoison.Response{status_code: 200, body: body}) do
    body |> Poison.decode!(keys: :atoms)
  end

  defp process_response(%HTTPoison.Response{status_code: code, body: body}) do
    decoded_body = body |> Poison.decode!(keys: :atoms)

    Mix.shell.error "Could not fetch the gist from GitHub: " <>
                    "#{code}: #{decoded_body.message}"
    Mix.raise "Installation failed"
  end
end
