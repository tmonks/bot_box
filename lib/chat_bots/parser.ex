defmodule ChatBots.Parser do
  @moduledoc """
  Parses messages from the chat API into chat items to be displayed in the chat window.
  """
  alias ChatBots.Chats.Bubble

  @doc """
  """
  def parse(%{content: content}) do
    # if valid JSON, parse the JSON
    content =
      case Jason.decode(content) do
        {:ok, decoded} -> decoded["response"]
        {:error, _} -> content
      end

    %Bubble{type: "bot", text: content}
  end
end
