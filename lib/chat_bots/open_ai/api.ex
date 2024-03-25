defmodule ChatBots.OpenAi.Api do
  alias ChatBots.OpenAi.Client
  alias ChatBots.Chats
  alias ChatBots.Chats.Message

  @model "gpt-3.5-turbo"

  @doc """
  Sends a message to the chat bot and returns the updated chat.
  """
  def send_message(messages, message_text) do
    user_message = %Message{
      role: "user",
      content: message_text
    }

    # create a list of maps from the chat messages
    message_maps =
      (messages ++ [user_message])
      |> Enum.map(&Map.from_struct(&1))

    case Client.chat_completion(model: @model, messages: message_maps) do
      {:ok, %{choices: [choice | _]}} ->
        assistant_message = choice["message"] |> create_message_from_map()

        updated_messages =
          messages
          |> Chats.add_message(user_message)
          |> Chats.add_message(assistant_message)

        {:ok, updated_messages}

      {:error, :timeout} ->
        {:error, %{"message" => "Your request timed out"}}

      {:error, error} ->
        {:error, error["error"]}
    end
  end

  defp create_message_from_map(map) do
    %Message{
      role: map["role"],
      content: map["content"]
    }
  end
end
