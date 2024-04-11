defmodule ChatBots.Chats do
  alias ChatBots.Bots
  alias ChatBots.Chats.Chat
  alias ChatBots.Chats.Message
  alias ChatBots.Repo

  import Ecto.Changeset, only: [change: 2, put_assoc: 3]

  @doc """
  Creates a new chat for the given bot_id.
  Adds a message with the bot's system prompt.
  """
  def create_chat(bot) do
    %Chat{}
    |> change(bot_id: bot.id)
    |> put_assoc(:messages, [%Message{role: "system", content: bot.directive}])
    |> Repo.insert!()
  end

  @doc """
  Retrieves a chat by id
  """
  def get_chat!(id) do
    Repo.get!(Chat, id)
    |> Repo.preload(:messages)
  end

  @doc """
  Creates a new message for the given chat
  """
  def create_message(chat, attrs) do
    %Message{}
    |> change(attrs)
    |> put_assoc(:chat, chat)
    |> Repo.insert!()
  end

  @doc """
  Creates a new chat with the given bot_id.
  """
  def new_chat(bot_id) do
    bot = Bots.get_bot(bot_id)
    system_prompt = %Message{role: "system", content: bot.directive}
    [system_prompt]
  end

  @doc """
  Adds a message to the chat.
  """
  def add_message(messages, message) do
    messages ++ [message]
  end
end
