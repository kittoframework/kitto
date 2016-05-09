# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :kitto, root: Path.dirname(__DIR__), port: 4000

# Use port: {:system, "PORT"} to have port port configurable via env variable
# Example: `PORT=4444 mix kitto.server` will start the server on port 4444

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]
