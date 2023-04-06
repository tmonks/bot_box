defmodule ChatBots.Repo do
  use Ecto.Repo,
    otp_app: :chat_bots,
    adapter: Ecto.Adapters.SQLite3
end
