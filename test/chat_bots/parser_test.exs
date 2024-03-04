defmodule ChatBots.ParserTest do
  use ChatBots.DataCase, async: true

  alias ChatBots.Chats.Bubble
  alias ChatBots.Chats.Message
  alias ChatBots.Parser

  test "parses a message from a text response" do
    response = %{
      role: "assistant",
      content: "Hello, world!"
    }

    assert %Bubble{type: "bot", text: "Hello, world!"} = Parser.parse(response)
  end

  test "parses a message from a JSON response" do
    response = %Message{
      role: "assistant",
      content: "{\n  \"response\": \"Hello, world!\"\n}"
    }

    assert %Bubble{type: "bot", text: "Hello, world!"} = Parser.parse(response)
  end
end
