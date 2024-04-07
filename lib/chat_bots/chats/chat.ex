defmodule ChatBots.Chats.Chat do
  use Ecto.Schema
  alias ChatBots.Bots.Bot
  alias ChatBots.Chats.Message

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "chats" do
    has_many(:messages, Message)
    belongs_to(:bot, Bot)

    timestamps()
  end
end
