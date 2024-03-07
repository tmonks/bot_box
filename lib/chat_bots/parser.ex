defmodule ChatBots.Parser do
  @moduledoc """
  Parses messages from the chat API into chat items to be displayed in the chat window.
  """
  alias ChatBots.Chats.Bubble
  alias ChatBots.Chats.Image

  @doc """
  """
  def parse(%{content: content}) do
    case Jason.decode(content) do
      {:ok, content_map} -> gather_chat_items(content_map)
      {_, _} -> [parse_chat_item(content)]
    end
  end

  defp gather_chat_items(content_map) do
    content_map
    |> Map.to_list()
    |> Enum.map(&parse_chat_item/1)
  end

  defp parse_chat_item({"text", response}), do: parse_chat_item(response)

  defp parse_chat_item({"image_prompt", prompt}) do
    %Image{prompt: prompt}
  end

  defp parse_chat_item(response) do
    %Bubble{type: "bot", text: response}
  end
end
