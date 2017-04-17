defmodule Mix.Tasks.Kitto.New do
  use Mix.Task
  import Mix.Generator

  @version Mix.Project.config[:version]
  @shortdoc "Creates a new Kitto v#{@version} application"
  @repo "https://github.com/kittoframework/kitto"

  # File mappings
  @lint {Credo.Check.Readability.MaxLineLength, false}
  @new [
    {:eex,  "new/config/config.exs",                    "config/config.exs"},
    {:text, "new/config/dev.exs",                       "config/dev.exs"},
    {:text, "new/config/prod.exs",                      "config/prod.exs"},
    {:eex,  "new/rel/config.exs",                       "rel/config.exs"},
    {:text, "new/rel/plugins/compile_assets_task.exs",  "rel/plugins/compile_assets_task.exs"},
    {:eex,  "new/mix.exs",                              "mix.exs"},
    {:eex,  "new/README.md",                            "README.md"},
    {:text, "new/.gitignore",                           ".gitignore"},
    {:text, "new/Dockerfile",                           "Dockerfile"},
    {:text, "new/.dockerignore",                        ".dockerignore"},
    {:text, "new/Procfile",                             "Procfile"},
    {:text, "new/elixir_buildpack.config",              "elixir_buildpack.config"},
    {:eex,  "new/lib/application_name.ex",              "lib/application_name.ex"},
    {:text, "new/dashboards/error.html.eex",            "dashboards/error.html.eex"},
    {:text, "new/dashboards/layout.html.eex",           "dashboards/layout.html.eex"},
    {:text, "new/dashboards/sample.html.eex",           "dashboards/sample.html.eex"},
    {:text, "new/dashboards/rotator.html.eex",          "dashboards/rotator.html.eex"},
    {:text, "new/dashboards/jobs.html.eex",             "dashboards/jobs.html.eex"},
    {:text, "new/widgets/clock/clock.js",               "widgets/clock/clock.js"},
    {:text, "new/widgets/clock/clock.scss",             "widgets/clock/clock.scss"},
    {:text, "new/widgets/graph/graph.js",               "widgets/graph/graph.js"},
    {:text, "new/widgets/graph/graph.scss",             "widgets/graph/graph.scss"},
    {:text, "new/widgets/image/image.js",               "widgets/image/image.js"},
    {:text, "new/widgets/image/image.scss",             "widgets/image/image.scss"},
    {:text, "new/widgets/list/list.js",                 "widgets/list/list.js"},
    {:text, "new/widgets/list/list.scss",               "widgets/list/list.scss"},
    {:text, "new/widgets/number/number.js",             "widgets/number/number.js"},
    {:text, "new/widgets/number/number.scss",           "widgets/number/number.scss"},
    {:text, "new/widgets/meter/meter.js",               "widgets/meter/meter.js"},
    {:text, "new/widgets/meter/meter.scss",             "widgets/meter/meter.scss"},
    {:text, "new/widgets/text/text.js",                 "widgets/text/text.js"},
    {:text, "new/widgets/text/text.scss",               "widgets/text/text.scss"},
    {:text, "new/widgets/time_took/time_took.js",       "widgets/time_took/time_took.js"},
    {:text, "new/widgets/time_took/time_took.scss",     "widgets/time_took/time_took.scss"},
    {:text, "new/jobs/phrases.exs",                     "jobs/phrases.exs"},
    {:text, "new/jobs/convergence.exs",                 "jobs/convergence.exs"},
    {:text, "new/jobs/buzzwords.exs",                   "jobs/buzzwords.exs"},
    {:text, "new/jobs/random.exs",                      "jobs/random.exs"},
    {:text, "new/jobs/stats.exs",                       "jobs/stats.exs"},
    {:keep, "new/assets/images",                        "assets/images/"},
    {:keep, "new/assets/fonts",                         "assets/fonts/"},
    {:text, "new/assets/javascripts/application.js",    "assets/javascripts/application.js"},
    {:text, "new/assets/stylesheets/application.scss",  "assets/stylesheets/application.scss"},
    {:keep, "new/public/assets",                        "public/assets"},
    {:text, "new/public/assets/favicon.ico",            "public/assets/favicon.ico"},
    {:text, "new/public/assets/images/placeholder.png", "public/assets/images/placeholder.png"},
    {:text, "new/webpack.config.js",                    "webpack.config.js"},
    {:text, "new/.babelrc",                             ".babelrc"},
    {:eex,  "new/package.json",                         "package.json"}
  ]

  # Embed all defined templates
  root = Path.expand("../templates", __DIR__)

  for {format, source, _} <- @new do
    unless format == :keep do
      @external_resource Path.join(root, source)
      def render(unquote(source)), do: unquote(File.read!(Path.join(root, source)))
    end
  end

  @moduledoc """
  Creates a new Kitto dashboard.

  It expects the path of the project as argument.

      mix kitto.new PATH [--edge] [--dev KITTO_PATH] [--app APP_NAME]

  A project at the given PATH will be created. The application name and module
  name will be retrieved from the path, unless otherwise provided.

  ## Options

  * `--edge` - use the `master` branch of Kitto as your dashboard's dependency
  * `--dev` - use a local copy of Kitto as your dashboard's dependency
  * `--app` - name of the OTP application and base module

  ## Examples

      # Create a new Kitto dashboard
      mix kitto.new hello_world

      # Create a new Kitto dashboard named `Foo` in `./hello_world`
      mix kitto.new hello_world --app foo

      # Create a new Kitto dashboard using the master branch to get the latest
      # Kitto features
      mix kitto.new hello_world --edge

      # Create a new Kitto dashboard using a local copy at ./kitto to test
      # development code in Kitto core
      mix kitto.new hello_world --dev ./kitto

  See: https://github.com/kittoframework/demo
  """

  def run([version]) when version in ~w(-v --version) do
    Mix.shell.info "Kitto v#{@version}"
  end

  def run(argv) do
    {opts, argv} =
      case OptionParser.parse(argv, switches: [edge: :boolean, dev: :string, app: :string]) do
        {opts, argv, []} ->
          {opts, argv}
        {_opts, _argv, [switch | _]} ->
          Mix.raise "Invalid option: " <> switch_to_string(switch)
      end

    case argv do
      [] -> Mix.Task.run "help", ["kitto.new"]
      [path|_] ->
        app = (opts[:app] || Path.basename(Path.expand(path))) |> String.downcase
        check_application_name!(app)
        mod = Macro.camelize(app)

        run(app, mod, path, opts)
    end
  end

  def run(app, mod, path, opts) do
    binding = [application_name: app,
               application_module: mod,
               kitto_dep: kitto_dep(opts),
               npm_kitto_dep: npm_kitto_dep(opts[:dev])]

    copy_from path, binding, @new

    ## Optional contents

    ## Parallel installs
    install? = Mix.shell.yes?("\nFetch and install dependencies?")

    File.cd!(path, fn ->
      mix?    = install_mix(install?)
      webpack? = install_webpack(install?)
      extra   = if mix?, do: [], else: ["$ mix deps.get"]

      print_mix_info(path, extra)
      if !webpack?, do: print_webpack_info()
    end)
  end

  defp switch_to_string({name, nil}), do: name
  defp switch_to_string({name, val}), do: name <> "=" <> val

  defp install_webpack(install?) do
    maybe_cmd "npm install",
              File.exists?("webpack.config.js"),
              install? && System.find_executable("npm")
  end

  defp install_mix(install?) do
    maybe_cmd "mix deps.get", true, install? && Code.ensure_loaded?(Hex)
  end

  defp print_mix_info(path, extra) do
    steps = ["$ cd #{path}"] ++ extra ++ ["$ mix kitto.server"]

    Mix.shell.info """

    We are all set! Run your Dashboard application:

        #{Enum.join(steps, "\n    ")}

    You can also run your app inside IEx (Interactive Elixir) as:

        $ iex -S mix
    """
  end

  defp print_webpack_info do
    Mix.shell.info """

    Kitto uses an assets build tool called webpack
    which requires node.js and npm. Installation instructions for
    node.js, which includes npm, can be found at http://nodejs.org.

    After npm is installed, install your webpack dependencies by
    running inside your app:

        $ npm install
    """
    nil
  end

  defp check_application_name!(app_name) do
    unless app_name =~ ~r/^[a-z][\w_]*$/ do
      Mix.raise "Application name must start with a letter and have only " <>
                "lowercase letters, numbers and underscore, " <>
                "received: #{inspect app_name}"
    end
  end

  ### Helpers

  defp maybe_cmd(cmd, should_run?, can_run?) do
    cond do
      should_run? && can_run? ->
        cmd(cmd)
        true
      should_run? ->
        false
      true ->
        true
    end
  end

  defp cmd(cmd) do
    Mix.shell.info [:green, "* running ", :reset, cmd]

    # We use :os.cmd/1 because there is a bug in OTP
    # where we cannot execute .cmd files on Windows.
    # We could use Mix.shell.cmd/1 but that automatically
    # outputs to the terminal and we don't want that.
    :os.cmd(String.to_char_list(cmd))
  end

  defp kitto_dep(opts) do
    cond do
      opts[:edge] -> ~s[{:kitto, github: "kittoframework/kitto", branch: "master"}]
      opts[:dev] -> ~s[{:kitto, path: "#{kitto_path(opts[:dev])}"}]
      true -> ~s[{:kitto, "~> #{@version}"}]
    end
  end

  defp npm_kitto_dep(path) when is_bitstring(path), do: kitto_path(path)
  defp npm_kitto_dep(_), do: "deps/kitto"

  defp kitto_path(path) do
    {:ok, cwd} = File.cwd()
    path = Path.join([cwd, path])

    if File.exists?(path) do
      path
    else
      install? = Mix.shell.yes?("\nKitto not found. Do you want to clone it?")
      maybe_cmd("git clone #{@repo}", true, install?)
      path
    end
  end

  ### Template helpers

  defp copy_from(target_dir, binding, mapping) when is_list(mapping) do
    application_name = Keyword.fetch!(binding, :application_name)

    for {format, source, target_path} <- mapping do
      target = Path.join(target_dir,
                         String.replace(target_path,
                                        "application_name",
                                        application_name))

      case format do
        :keep ->
          File.mkdir_p!(target)
        :text ->
          create_file(target, render(source))
        :append ->
          append_to(Path.dirname(target), Path.basename(target), render(source))
        :eex  ->
          contents = EEx.eval_string(render(source), binding, file: source)
          create_file(target, contents)
      end
    end
  end

  defp append_to(path, file, contents) do
    file = Path.join(path, file)
    File.write!(file, File.read!(file) <> contents)
  end
end
