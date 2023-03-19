defmodule ChatBots.Chats do
  alias ChatBots.Chats.Chat

  @doc """
  Creates a new chat with the given bot_id.
  """
  def new_chat(bot_id) do
    %Chat{bot_id: bot_id, messages: []}
  end

  @doc """
  Adds a message to the chat.
  """
  def add_message(chat, message) do
    %Chat{chat | messages: [message | chat.messages]}
  end
end
