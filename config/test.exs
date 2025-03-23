import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :chat_bots, ChatBotsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "XnEW3P7d5iq2ANIHOIOgFjszS4r5TvOcpF2jBVhng5G/hlDCE1EXCWPopnCJTVi5",
  server: false

# Configure your database
config :chat_bots, ChatBots.Repo,
  database: Path.expand("../chatbots_test.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# set download path for generated images to /tmp
config :chat_bots, :download_path, "/tmp"
