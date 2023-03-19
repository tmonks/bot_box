defmodule ChatBots.ChatApiTest do
  use ExUnit.Case
  import Mox
  alias ChatBots.OpenAi.MockClient
  alias ChatBots.ChatApi
  alias ChatBots.Chats
  alias ChatBots.Chats.Message

  # mocks need to be verified when the test exits
  setup :verify_on_exit!

  test "send_message/2 adds a response to the chat" do
    chat = Chats.new_chat("echo")
    message_text = "What is the meaning of life?"

    # Set up the mock and assert the message is sent to the client
    MockClient
    |> expect(:chat_completion, fn args ->
      assert [model: _, messages: [%Message{role: "user", content: ^message_text}]] = args
      success_fixture()
    end)

    {:ok, updated_chat} = ChatApi.send_message(chat, message_text)

    # assert the last message in the updated_chat is "42
    assert %{role: "user", content: ^message_text} = updated_chat.messages |> Enum.at(-2)
    assert %{role: "assistant", content: "42"} = updated_chat.messages |> Enum.at(-1)
  end

  defp success_fixture do
    {:ok,
     %{
       choices: [
         %{
           "finish_reason" => "stop",
           "index" => 0,
           "message" => %{
             "content" => "42",
             "role" => "assistant"
           }
         }
       ],
       created: 1_679_238_705,
       id: "chatcmpl-6vozBYg28ott0ZfyQFPTH3kEQnbQ1",
       model: "gpt-3.5-turbo-0301",
       object: "chat.completion",
       usage: %{"completion_tokens" => 38, "prompt_tokens" => 27, "total_tokens" => 65}
     }}
  end
end
