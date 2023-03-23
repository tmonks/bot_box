defmodule ChatBots.Chats do
  alias ChatBots.Chats.{Chat, Message}
  alias ChatBots.Bots

  @doc """
  Creates a new chat with the given bot_id.
  """
  def new_chat(bot_id) do
    bot = Bots.get_bot(bot_id)
    system_prompt = %Message{role: "system", content: bot.directive}
    %Chat{bot_id: bot_id, messages: [system_prompt]}
  end

  @doc """
  Adds a message to the chat.
  """
  # TODO: enforce that it only accepts a %Message struct
  def add_message(chat, message) do
    %Chat{chat | messages: chat.messages ++ [message]}
  end
end
