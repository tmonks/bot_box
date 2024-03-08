defmodule ChatBots.StabilityAi.Client do
  @moduledoc """
  Behaviour for a client that communicates with the Stability AI API
  """

  def impl do
    Application.get_env(:chat_bots, :stability_ai_client, ChatBots.StabilityAi.HttpClient)
  end

  @callback post(url :: String.t(), options :: keyword()) ::
              {:ok, Req.Response.t()} | {:error, Exception.t()}

  def post(url, options), do: impl().post(url, options)
end
