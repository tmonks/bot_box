defmodule ChatBots.ChatApi do
  alias ChatBots.OpenAi.Client
  alias ChatBots.Chats
  alias ChatBots.Chats.{Chat, Message}

  @model "gpt-3.5-turbo"

  @doc """
  Sends a message to the chat bot and returns the updated chat.
  """
  def send_message(%Chat{} = chat, message_text) do
    user_message = %Message{
      role: "user",
      content: message_text
    }

    case Client.chat_completion(model: @model, messages: chat.messages ++ [user_message]) do
      {:ok, %{choices: [choice | _]}} ->
        assistant_message = choice["message"] |> convert_string_keys_to_atoms()

        updated_chat =
          chat
          |> Chats.add_message(user_message)
          |> Chats.add_message(assistant_message)

        {:ok, updated_chat}

      {:error, error} ->
        IO.inspect(error)
        {:error, chat}
    end
  end

  defp convert_string_keys_to_atoms(map) do
    map
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
  end
end
