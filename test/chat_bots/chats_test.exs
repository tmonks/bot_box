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
end
