defmodule ChatBots.ChatsTest do
  use ChatBots.DataCase
  alias ChatBots.Chats.{Chat, Message}
  alias ChatBots.Chats
  import ChatBots.Fixtures

  test "new_chat/1 returns a Chat with the specified bot's id and system prompt" do
    bot = bot_fixture()
    assert %Chat{} = chat = Chats.new_chat(bot.id)
    assert chat.bot_id == bot.id
    assert [%Message{role: "system", content: "You are a helpful assistant."}] = chat.messages
  end

  test "add_message/2 adds a message to the chat" do
    bot = bot_fixture()
    chat = Chats.new_chat(bot.id)
    message = %Message{content: "Hello", role: "user"}

    chat = Chats.add_message(chat, message)
    assert [_system_prompt, ^message] = chat.messages
  end

  test "add_message/2 adds a message to the end of the chat" do
    bot = bot_fixture()
    chat = Chats.new_chat(bot.id)
    message1 = %Message{content: "User message", role: "user"}
    message2 = %Message{content: "Assistant response", role: "assistant"}

    chat = Chats.add_message(chat, message1)
    chat = Chats.add_message(chat, message2)
    assert [_system_prompt, ^message1, ^message2] = chat.messages
  end
end
