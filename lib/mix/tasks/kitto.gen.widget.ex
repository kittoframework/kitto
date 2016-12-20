defmodule Mix.Tasks.Kitto.Gen.Widget do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Generates a new widget"

  @templates Path.join Path.expand("./templates", __DIR__), "widget"

  @moduledoc """
  Generates a new widget

  Usage:

      $ mix kitto.gen.widget this_widget
      # generates `widgets/this_widget/this_widget.js` and
      # `widgets/this_widget/this_widget.scss`
  """

  def run(argv) do
    case List.first(argv) do
      nil ->
        IO.puts """
        No widget name provided.

        Usage:

            mix kitto.gen.widget this_widget
        """
        exit :no_widget
      widget ->
        widget_dir = Path.join("widgets", widget)
        create_directory widget_dir
        create_file Path.join(widget_dir, "#{widget}.scss"), EEx.eval_file(scss, [name: widget])
        create_file Path.join(widget_dir, "#{widget}.js"), EEx.eval_file(scss, [name: widget, class: classify(widget)])
    end
  end

  defp classify(widget), do: Macro.camelize(widget)

  defp javascript, do: Path.join(@templates, "widget.js.eex")
  defp scss, do: Path.join(@templates, "widget.scss.eex")
end
