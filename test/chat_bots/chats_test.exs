defmodule ChatBots.ChatsTest do
  use ExUnit.Case
  alias ChatBots.Chats.{Chat, Message}
  alias ChatBots.Chats

  test "new_chat/1 returns a Chat with expected attributes" do
    assert %Chat{} = chat = Chats.new_chat("echo")
    assert chat.bot_id == "echo"
    assert chat.messages == []
  end

  test "add_message/2 adds a message to the chat" do
    chat = Chats.new_chat("echo")
    message = %Message{content: "Hello", role: "user"}

    chat = Chats.add_message(chat, message)
    assert [^message] = chat.messages
  end

  test "add_message/2 adds a message to the end of the chat" do
    chat = Chats.new_chat("echo")
    message1 = %Message{content: "User message", role: "user"}
    message2 = %Message{content: "Assistant response", role: "assistant"}

    chat = Chats.add_message(chat, message1)
    chat = Chats.add_message(chat, message2)
    assert [^message1, ^message2] = chat.messages
  end
end
