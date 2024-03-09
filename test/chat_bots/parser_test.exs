defmodule ChatBots.ParserTest do
  use ChatBots.DataCase, async: true

  alias ChatBots.Chats.Bubble
  alias ChatBots.Chats.Image
  alias ChatBots.Chats.Message
  alias ChatBots.Parser

  test "parses a message from a text response" do
    response = %{
      role: "assistant",
      content: "Hello, world!"
    }

    assert [%Bubble{type: "bot", text: "Hello, world!"}] = Parser.parse(response)
  end

  test "parses a message from a text repsonse containing only a number" do
    response = %{
      role: "assistant",
      content: "42"
    }

    assert [%Bubble{type: "bot", text: "42"}] = Parser.parse(response)
  end

  test "parses a message from a JSON response" do
    response = make_json_message(%{text: "Hello, world!"})

    assert [%Bubble{type: "bot", text: "Hello, world!"}] = Parser.parse(response)
  end

  test "parses an Image from a JSON response" do
    response =
      make_json_message(%{
        text: "Hello, world!",
        image_prompt: "An image of a duck wearing a hat"
      })

    assert [%Image{prompt: "An image of a duck wearing a hat"}, _bubble] = Parser.parse(response)
  end

  defp make_json_message(response_json) do
    json = Jason.encode!(response_json)

    %Message{
      role: "assistant",
      content: json
    }
  end
end
