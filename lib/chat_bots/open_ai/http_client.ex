defmodule ChatBots.OpenAi.HttpClient do
  @moduledoc """
  An HTTP client for OpenAI.
  """
  @behaviour ChatBots.OpenAi.Client

  @impl true
  def chat_completion(params) do
    OpenAI.chat_completion(params)
  end
end
