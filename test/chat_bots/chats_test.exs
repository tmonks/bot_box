defmodule ChatBots.ChatsTest do
  use ExUnit.Case
  alias ChatBots.Chats.{Chat, Message}
  alias ChatBots.Chats

  test "new_chat/1 returns a Chat with the specified bot's id and system prompt" do
    assert %Chat{} = chat = Chats.new_chat("test_bot")
    assert chat.bot_id == "test_bot"
    assert [%Message{role: "system", content: "You are a helpful assistant."}] = chat.messages
  end

  test "add_message/2 adds a message to the chat" do
    chat = Chats.new_chat("test_bot")
    message = %Message{content: "Hello", role: "user"}

    chat = Chats.add_message(chat, message)
    assert [_system_prompt, ^message] = chat.messages
  end

  test "add_message/2 adds a message to the end of the chat" do
    chat = Chats.new_chat("test_bot")
    message1 = %Message{content: "User message", role: "user"}
    message2 = %Message{content: "Assistant response", role: "assistant"}

    chat = Chats.add_message(chat, message1)
    chat = Chats.add_message(chat, message2)
    assert [_system_prompt, ^message1, ^message2] = chat.messages
  end
end
