defmodule ChatBots.OpenAi.ApiTest do
  use ChatBots.DataCase

  import Mox
  import ChatBots.Fixtures
  alias ChatBots.OpenAi.MockClient
  alias ChatBots.OpenAi.Api
  alias ChatBots.Chats
  alias ChatBots.Chats.Message
  import ChatBots.Fixtures

  # mocks need to be verified when the test exits
  setup :verify_on_exit!

  test "send_message/2 adds a response to the chat" do
    bot = bot_fixture()
    chat = Chats.new_chat(bot.id)
    message_text = "What is the meaning of life?"

    # Set up the mock and assert the message is sent to the client as a map
    MockClient
    |> expect(:chat_completion, fn [model: _, messages: messages] ->
      assert [system_prompt, user_prompt] = messages
      assert system_prompt == %{role: "system", content: "You are a helpful assistant."}
      assert user_prompt == %{role: "user", content: message_text}
      api_success_fixture("42")
    end)

    {:ok, updated_chat} = Api.send_message(chat, message_text)

    # assert the last message in the updated_chat is "42
    assert %Message{role: "user", content: ^message_text} = updated_chat.messages |> Enum.at(-2)
    assert %Message{role: "assistant", content: "42"} = updated_chat.messages |> Enum.at(-1)
  end

  test "send_message/2 returns an error tuple if the client returns an error" do
    bot = bot_fixture()
    chat = Chats.new_chat(bot.id)
    message_text = "What is the meaning of life?"

    # Set up the mock and assert the message is sent to the client as a map
    MockClient |> expect(:chat_completion, fn _ -> api_error_fixture() end)

    assert {:error, error} = Api.send_message(chat, message_text)
    assert error["message"] == "Invalid request"
  end

  test "send_message/2 can handle a :timeout error" do
    bot = bot_fixture()
    chat = Chats.new_chat(bot.id)
    message_text = "What is the meaning of life?"

    # Set up the mock and assert the message is sent to the client as a map
    MockClient |> expect(:chat_completion, fn _ -> api_timeout_fixture() end)

    assert {:error, error} = Api.send_message(chat, message_text)
    assert error["message"] == "Your request timed out"
  end
end
