# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :weatherbot,
  ecto_repos: [Weatherbot.Repo]

# Configures the endpoint
config :weatherbot, Weatherbot.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "UrMTfZE2ytXsFp3dAY47PryWAkfC8oCuLgfbInqLEA6tsqlGFkBfyrr2S8ns1gBk",
  render_errors: [view: Weatherbot.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Weatherbot.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "config.secret.exs"

import_config "#{Mix.env}.exs"
