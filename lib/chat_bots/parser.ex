defmodule ChatBots.Parser do
  @moduledoc """
  Parses messages from the chat API into chat items to be displayed in the chat window.
  """
  alias ChatBots.Chats.Bubble
  alias ChatBots.Chats.ImageRequest

  @doc """
  Parses a chat response into a list of chat items
  """
  def parse(%{content: content, role: "assistant"}) do
    maybe_decode_json(content)
    |> gather_chat_items()
  end

  def parse(%{content: content, role: role}) do
    [%Bubble{type: role, text: content}]
  end

  defp maybe_decode_json(text) do
    case Jason.decode(text) do
      {:ok, map} -> map
      {_, _} -> text
    end
  end

  defp gather_chat_items(content_map) when is_map(content_map) do
    content_map
    |> Map.to_list()
    |> Enum.map(&parse_chat_item/1)
    |> List.flatten()
  end

  defp gather_chat_items(content_map), do: parse_chat_item(content_map)

  defp parse_chat_item({"text", response}), do: parse_chat_item(response)

  defp parse_chat_item({"image_prompt", prompt}) do
    %ImageRequest{prompt: prompt}
  end

  defp parse_chat_item(response) when is_binary(response) do
    response
    |> String.split("\n\n")
    |> Enum.map(&%Bubble{type: "bot", text: &1})
  end

  defp parse_chat_item(response) do
    [%Bubble{type: "bot", text: "#{response}"}]
  end

  @doc """
  Parses an image_prompt if present in the JSON response
  """
  def parse_image_prompt(%{content: content, role: "assistant"}) do
    maybe_decode_json(content)
    |> parse_image_prompt()
  end

  def parse_image_prompt(%{"image_prompt" => prompt}), do: prompt

  def parse_image_prompt(_), do: nil
end
