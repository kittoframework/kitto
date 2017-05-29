use Mix.Config

config :kitto, root: Path.dirname(__DIR__)
config :kitto, templates_dir: "test/fixtures/views"
config :kitto, default_layout: "layout"
config :kitto, otp_app: :kitto

config :logger, level: :warn
