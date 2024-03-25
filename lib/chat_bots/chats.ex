defmodule ChatBots.Chats do
  alias ChatBots.Chats.Message
  alias ChatBots.Bots

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
