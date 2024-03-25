defmodule ChatBots.ChatsTest do
  use ChatBots.DataCase
  alias ChatBots.Chats
  alias ChatBots.Chats.Message
  import ChatBots.Fixtures

  test "new_chat/1 returns a list of messages containing the bot's system prompt" do
    bot = bot_fixture()

    assert [%Message{role: "system", content: "You are a helpful assistant."}] =
             Chats.new_chat(bot.id)
  end

  test "add_message/2 adds a message to the chat" do
    bot = bot_fixture()
    messages = Chats.new_chat(bot.id)
    message = %Message{content: "Hello", role: "user"}

    assert [_system_prompt, ^message] = Chats.add_message(messages, message)
  end

  test "add_message/2 adds a message to the end of the chat" do
    bot = bot_fixture()
    messages = Chats.new_chat(bot.id)
    message1 = %Message{content: "User message", role: "user"}
    message2 = %Message{content: "Assistant response", role: "assistant"}

    messages = Chats.add_message(messages, message1)
    messages = Chats.add_message(messages, message2)
    assert [_system_prompt, ^message1, ^message2] = messages
  end
end
