# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :chat_bots,
  namespace: ChatBots,
  ecto_repos: [ChatBots.Repo]

# Configures the endpoint
config :chat_bots, ChatBotsWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: ChatBotsWeb.ErrorHTML, json: ChatBotsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ChatBots.PubSub,
  live_view: [signing_salt: "r7hZC7wE"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# OpenAI API configuration
config :openai,
  api_key: System.get_env("OPENAI_API_KEY"),
  organization_key: System.get_env("OPENAI_ORG_KEY"),
  http_options: [recv_timeout: 30_000]

# dev/test defaults for admin auth
config :chat_bots, :auth, username: "bbuser", password: "Password123!"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
