defmodule ChatBots.OpenAi.ApiTest do
  use ChatBots.DataCase

  import Mox
  import ChatBots.Fixtures
  import ChatBots.Factory

  alias ChatBots.OpenAi.MockClient
  alias ChatBots.OpenAi.Api
  alias ChatBots.Chats
  alias ChatBots.Chats.Message

  # mocks need to be verified when the test exits
  setup :verify_on_exit!

  describe "send_message/2" do
    test "sends a message and returns an assistant message" do
      bot = insert(:bot)
      message_text = "What is the meaning of life?"
      messages = messages_fixture(message_text)

      # Set up the mock and assert the message is sent to the client as a map
      MockClient
      |> expect(:chat_completion, fn params ->
        messages = params[:messages]
        assert [system_prompt, user_prompt] = messages
        assert system_prompt == %{role: "system", content: "You are a helpful assistant."}
        assert user_prompt == %{role: "user", content: message_text}
        api_success_fixture("42")
      end)

      {:ok, message} = Api.send_message(bot, messages)

      assert %{"role" => "assistant", "content" => "42"} = message
    end

    test "returns an error tuple if the client returns an error" do
      bot = insert(:bot)
      message_text = "What is the meaning of life?"
      messages = messages_fixture(message_text)

      # Set up the mock and assert the message is sent to the client as a map
      MockClient |> expect(:chat_completion, fn _ -> api_error_fixture() end)

      assert {:error, error} = Api.send_message(bot, messages)
      assert error["message"] == "Invalid request"
    end

    test "can handle a :timeout error" do
      bot = insert(:bot)
      message_text = "What is the meaning of life?"
      messages = messages_fixture(message_text)

      # Set up the mock and assert the message is sent to the client as a map
      MockClient |> expect(:chat_completion, fn _ -> api_timeout_fixture() end)

      assert {:error, error} = Api.send_message(bot, messages)
      assert error["message"] == "Your request timed out"
    end

    test "requests json response for bot that uses json_mode" do
      bot = insert(:bot, %{json_mode: true})
      messages = messages_fixture("What is the meaning of life?")

      MockClient
      |> expect(:chat_completion, fn params ->
        assert {:response_format, %{type: "json_object"}} in params
        api_success_fixture("{\"text\": \"42\}")
      end)

      {:ok, _message} = Api.send_message(bot, messages)
    end
  end

  defp messages_fixture(message_text) do
    bot = bot_fixture()

    Chats.new_chat(bot.id)
    |> Chats.add_message(%Message{role: "user", content: message_text})
    |> Enum.map(&Map.take(&1, [:role, :content]))
  end
end
