defmodule ChatBots.OpenAi.Client do
  @moduledoc """
  Defines the behaviour for an OpenAI client.
  """

  alias ChatBots.Chats.Message

  @callback chat_completion(model: String.t(), messages: [Message.t()]) ::
              {:ok, map()} | {:error, map()}

  def chat_completion(model: model, messages: messages) do
    client().chat_completion(model: model, messages: messages)
  end

  defp client do
    # The client to use will be set in the Application environment
    # The third argument sets the default to the HttpClient
    # This can be overridden in test_helper.ex with a mock for testing
    Application.get_env(:chat_bots, :open_ai_client, ChatBots.OpenAi.HttpClient)
  end
end
