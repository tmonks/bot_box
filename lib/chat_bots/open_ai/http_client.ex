defmodule ChatBots.OpenAi.HttpClient do
  @moduledoc """
  An HTTP client for OpenAI.
  """
  @behaviour ChatBots.OpenAi.Client

  @impl true
  def chat_completion(model: model, messages: messages) do
    OpenAI.chat_completion(model: model, messages: messages)
  end
end
