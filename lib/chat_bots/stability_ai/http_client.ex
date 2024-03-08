defmodule ChatBots.StabilityAi.HttpClient do
  @behaviour ChatBots.StabilityAi.Client

  @impl true
  def post(url, options), do: Req.post(url, options)
end
