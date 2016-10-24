# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :kitto, root: System.cwd
config :kitto, templates_dir: "dashboards"
config :kitto, default_layout: "layout"
config :kitto, default_dashboard: "sample"

if File.exists?(Path.join("config", "#{Mix.env}.exs")) do
  import_config "#{Mix.env}.exs"
end
