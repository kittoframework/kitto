# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :kitto, root: Path.dirname(__DIR__), port: 4000

# Use code_reload?: false to disable code reloading in development environment
# Read More: https://github.com/kittoframework/kitto/wiki/Code-Reloading

# Use ip: {:system, "KITTO_IP"} to have binding ip configurable via env variable
# Example: `KITTO_IP=0.0.0.0 mix kitto.server` will start the server on 0.0.0.0

# Use port: {:system, "KITT0_PORT"} to have port port configurable via env variable
# Example: `KITTO_PORT=4444 mix kitto.server` will start the server on port 4444

# Change the binding ip of the asset watcher server
# config :kitto, assets_host: "127.0.0.1"

# Change the binding port of the asset watcher server
# config :kitto, assets_port: 8080

# Use default_dashboard: "your-dashboard" to specify the dashboard to be served
# when the root path is requested.

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Add authentication to `PORT /widgets/:id`. Change "asecret" to something more
# secure.
#
# config :kitto, :auth_token: "asecret"
