defmodule ChatBots.OpenAi.Api do
  alias ChatBots.OpenAi.Client

  @model "gpt-3.5-turbo"

  @doc """
  Sends a message to the chat bot and returns the updated chat.
  """
  def send_message(messages) do
    case Client.chat_completion(model: @model, messages: messages) do
      {:ok, %{choices: [choice | _]}} ->
        {:ok, choice["message"]}

      {:error, :timeout} ->
        {:error, %{"message" => "Your request timed out"}}

      {:error, error} ->
        {:error, error["error"]}
    end
  end
end
