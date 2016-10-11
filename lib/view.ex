defmodule Kitto.View do
  @templates_dir Application.get_env :kitto, :templates_dir, "dashboards"
  @default_layout Application.get_env :kitto, :default_layout, "layout"

  def render(template, context) do
    |> EEx.eval_file([template: render_template(template, context)] ++
                     context |> merge_context)
  end

  def exists?(template), do: path(template) |> File.exists?

  def partial(template, context) do
    render_template(Path.join("partials", template), context)
  end

  defp merge_context(context), do: context ++ default_context
  defp render_template(template, context) do
    path(template) |> EEx.eval_file(context |> merge_context)
  end
  defp path(template), do: Path.join templates_path, "#{template}.html.eex"
  defp templates_path, do: Path.join System.cwd, @templates_dir
  defp default_context, do: [partial: &partial/2]
end
