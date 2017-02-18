defmodule Mix.Tasks.Kitto.Gen.Widget do
  use Mix.Task
  import Mix.Generator
  import Kitto.Generator

  @shortdoc "Generates a new widget"

  @templates Path.join Path.expand("./templates", __DIR__), "widget"

  @moduledoc """
  Generates a new widget

  Usage:

      $ mix kitto.gen.widget this_widget
      # generates `widgets/this_widget/this_widget.js` and
      # `widgets/this_widget/this_widget.scss`
  """

  @doc false
  def run(argv) do
    {opts, args, _} = parse_options(argv)
    case List.first(args) do
      nil ->
        Mix.shell.error """
        Usage:

            mix kitto.gen.widget this_widget
        """
        Mix.raise "No widget name provided"
      widget ->
        widget_dir = Path.join(opts[:path] || "widgets", widget)
        create_directory widget_dir
        create_file Path.join(widget_dir, "#{widget}.scss"), EEx.eval_file(scss(), [name: widget])
        create_file Path.join(widget_dir, "#{widget}.js"), EEx.eval_file(
          javascript(), [name: widget, class: classify(widget)]
        )
    end
  end

  defp classify(widget), do: Macro.camelize(widget)

  defp javascript, do: Path.join(@templates, "widget.js.eex")
  defp scss, do: Path.join(@templates, "widget.scss.eex")
end
