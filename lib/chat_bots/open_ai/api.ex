defmodule ChatBots.OpenAi.Api do
  alias ChatBots.OpenAi.Client

  @model "gpt-3.5-turbo"

  @doc """
  Sends a message to the chat bot and returns the updated chat.
  """
  def send_message(bot, messages) do
    params = prepare_params(bot, messages)

    case Client.chat_completion(params) do
      {:ok, %{choices: [choice | _]}} ->
        {:ok, choice["message"]}

      {:error, :timeout} ->
        {:error, %{"message" => "Your request timed out"}}

      {:error, error} ->
        {:error, error["error"]}
    end
  end

  defp prepare_params(bot, messages) do
    [messages: messages]
    |> add_model()
    |> maybe_add_json_mode(bot)
  end

  defp add_model(params) do
    params ++ [model: @model]
  end

  defp maybe_add_json_mode(params, bot) do
    if bot.json_mode do
      params ++ [response_format: %{type: "json_object"}]
    else
      params
    end
  end
end
