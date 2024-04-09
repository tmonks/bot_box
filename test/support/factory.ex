defmodule ChatBots.Factory do
  use ExMachina.Ecto, repo: ChatBots.Repo

  alias ChatBots.Bots.Bot
  alias ChatBots.Chats.Chat
  alias ChatBots.Chats.Message

  def bot_factory do
    %Bot{
      name: "Test Bot",
      directive: "You are a helpful assistant."
    }
  end

  def chat_factory do
    %Chat{
      bot: build(:bot)
    }
  end

  def message_factory do
    %Message{
      chat: build(:chat),
      role: "system",
      content: "You are a helpful assistant."
    }
  end
end
