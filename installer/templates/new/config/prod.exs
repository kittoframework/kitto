use Mix.Config

config :kitto, reload_code?: false, watch_assets?: false, serve_assets?: true

# For distillery releases
# Read more: https://github.com/kittoframework/kitto/wiki/%5BDeployment%5D-Distillery
# config :kitto, root: :otp_app

# For heroku deployments
# Read more: https://github.com/kittoframework/kitto/wiki/%5BDeployment%5D-Heroku
# config :kitto, assets_path: "priv/static"
