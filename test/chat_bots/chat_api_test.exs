defmodule ChatBots.ChatApiTest do
  use ExUnit.Case

  import Mox
  import ChatBots.Fixtures
  alias ChatBots.OpenAi.MockClient
  alias ChatBots.ChatApi
  alias ChatBots.Chats

  # mocks need to be verified when the test exits
  setup :verify_on_exit!

  test "send_message/2 adds a response to the chat" do
    chat = Chats.new_chat("test_bot")
    message_text = "What is the meaning of life?"

    # Set up the mock and assert the message is sent to the client as a map
    MockClient
    |> expect(:chat_completion, fn [model: _, messages: messages] ->
      assert [system_prompt, user_prompt] = messages
      assert system_prompt == %{role: "system", content: "You are a helpful assistant."}
      assert user_prompt == %{role: "user", content: message_text}
      api_success_fixture()
    end)

    {:ok, updated_chat} = ChatApi.send_message(chat, message_text)

    # assert the last message in the updated_chat is "42
    assert %{role: "user", content: ^message_text} = updated_chat.messages |> Enum.at(-2)
    assert %{role: "assistant", content: "42"} = updated_chat.messages |> Enum.at(-1)
  end

  test "send_message/2 returns an error tuple if the client returns an error" do
    chat = Chats.new_chat("test_bot")
    message_text = "What is the meaning of life?"

    # Set up the mock and assert the message is sent to the client as a map
    MockClient |> expect(:chat_completion, fn _ -> api_error_fixture() end)

    assert {:error, error} = ChatApi.send_message(chat, message_text)
    assert error["message"] == "Invalid request"
  end
end
