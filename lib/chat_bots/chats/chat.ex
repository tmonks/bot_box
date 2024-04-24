defmodule ChatBots.Chats.Chat do
  use Ecto.Schema
  alias ChatBots.Bots.Bot
  alias ChatBots.Chats.Message

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "chats" do
    belongs_to(:bot, Bot)
    has_many(:messages, Message)
    has_one(:latest_message, Message)

    timestamps()
  end
end
