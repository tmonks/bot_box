defmodule ChatBots.ChatsTest do
  use ChatBots.DataCase
  alias ChatBots.Chats
  alias ChatBots.Chats.Chat
  alias ChatBots.Chats.Message

  import ChatBots.Fixtures
  import ChatBots.Factory

  test "create_chat/1 creates a new chat for a bot" do
    bot = %{id: bot_id} = insert(:bot)

    assert %Chat{bot_id: ^bot_id} = Chats.create_chat(bot)
  end

  test "create_chat/1 creates a chat with the bot's system prompt" do
    bot = bot_fixture()

    assert %Chat{messages: messages} = Chats.create_chat(bot)
    assert [%Message{role: "system", content: "You are a helpful assistant."}] = messages
  end

  test "get_chat!/1 returns the chat for a bot" do
    %{id: chat_id} = insert(:chat)

    assert %Chat{id: ^chat_id} = Chats.get_chat!(chat_id)
  end

  test "get_chat!/1 preloads messages" do
    chat = insert(:chat, messages: [%{role: "system", content: "You are a helpful assistant."}])

    assert [%Message{role: "system", content: "You are a helpful assistant."}] =
             Chats.get_chat!(chat.id).messages
  end

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

  test "create_message/2 creates a new message on the given chat" do
    chat = %{id: chat_id} = insert(:chat)
    attrs = %{role: "user", content: "Hello"}

    assert {:ok, %Message{chat_id: ^chat_id, role: "user", content: "Hello"}} =
             Chats.create_message(chat, attrs)
  end

  test "list_chats/0 lists all existing chats" do
    %{id: id} = insert(:chat)

    assert [%Chat{id: ^id}] = Chats.list_chats()
  end

  test "list_chats/0 preloads messages" do
    chat = insert(:chat)
    %{id: message_id} = insert(:message, chat: chat)

    assert [chat] = Chats.list_chats()
    assert [%Message{id: ^message_id}] = chat.messages
  end

  test "list_chats/0 preloads the latest_message for each chat" do
    chat = insert(:chat)
    %{id: latest_message_id} = insert(:message, chat: chat, inserted_at: Timex.now())
    insert(:message, chat: chat, inserted_at: Timex.now() |> Timex.shift(hours: -1))
    insert(:message, chat: chat, inserted_at: Timex.now() |> Timex.shift(hours: -2))

    assert [chat] = Chats.list_chats()
    assert %Message{id: ^latest_message_id} = chat.latest_message
  end

  test "list_chats/0 preloads bot" do
    bot = insert(:bot, name: "Bob")
    chat = insert(:chat, bot: bot)
    insert(:message, chat: chat)

    assert [%Chat{bot: ^bot}] = Chats.list_chats()
  end
end
