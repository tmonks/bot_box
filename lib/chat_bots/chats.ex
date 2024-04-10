defmodule ChatBots.Chats do
  alias ChatBots.Bots
  alias ChatBots.Chats.Chat
  alias ChatBots.Chats.Message
  alias ChatBots.Repo

  @doc """
  Creates a new chat for the given bot_id.
  """
  def create_chat(bot) do
    %Chat{}
    |> Ecto.Changeset.change(bot_id: bot.id)
    |> Repo.insert!()
  end

  @doc """
  Retrieves a chat by id
  """
  def get_chat!(id) do
    Repo.get!(Chat, id)
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
