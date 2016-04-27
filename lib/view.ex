defmodule Kitto.View do
  @templates_dir "dashboards"
  @default_layout "layout"

  def render(template) do
    find_template(@default_layout) |> EEx.eval_file([template: render_template(template)])
  end

  defp render_template(template), do: find_template(template) |> EEx.eval_file
  defp find_template(template), do: Path.join templates_path, "#{template}.html.eex"
  defp templates_path, do: Path.join System.cwd, @templates_dir
end
