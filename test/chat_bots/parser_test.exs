defmodule ChatBots.ParserTest do
  use ChatBots.DataCase, async: true

  alias ChatBots.Chats.Bubble
  alias ChatBots.Chats.Image
  alias ChatBots.Chats.Message
  alias ChatBots.Parser

  describe "parse/1" do
    test "parses a Bubble from a text response" do
      response = %{
        role: "assistant",
        content: "Hello, world!"
      }

      assert [%Bubble{type: "bot", text: "Hello, world!"}] = Parser.parse(response)
    end

    test "can parse a Bubble from a user message" do
      response = %{
        role: "user",
        content: "Hello, world!"
      }

      assert [%Bubble{type: "user", text: "Hello, world!"}] = Parser.parse(response)
    end

    test "can parse a Bubble from an info message" do
      response = %{
        role: "info",
        content: "Bot has entered the chat"
      }

      assert [%Bubble{type: "info", text: "Bot has entered the chat"}] = Parser.parse(response)
    end

    test "splits mult-line content into multiple Bubbles from a text response" do
      response = %{
        role: "assistant",
        content: "Hello, world!\n\nHow are you?"
      }

      assert [
               %Bubble{type: "bot", text: "Hello, world!"},
               %Bubble{type: "bot", text: "How are you?"}
             ] = Parser.parse(response)
    end

    test "returns nil if there is no UI content in the response (such as an image prompt)" do
      response =
        %{role: "assistant", content: %{image_prompt: "An image of a cat"}} |> make_json_message()

      assert [] = Parser.parse(response)
    end

    test "parses a message from a text response containing only a number" do
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

    test "splits multi-line content into multiple Bubbles from a JSON response" do
      response = make_json_message(%{text: "Hello, world!\n\nHow are you?"})

      assert [
               %Bubble{type: "bot", text: "Hello, world!"},
               %Bubble{type: "bot", text: "How are you?"}
             ] = Parser.parse(response)
    end

    test "can parse an image do from a JSON response" do
      response =
        make_json_message(%{
          role: "image",
          content: %{file: "/path/to/image.jpg", prompt: "An image of a cat"}
        })

      assert [%Image{file: "/path/to/image.jpg", prompt: "An image of a cat"}] =
               Parser.parse(response)
    end
  end

  describe "parse_image_prompt/1" do
    test "parses an image response from a JSON response" do
      response = make_json_message(%{image_prompt: "An image of a cat"})

      assert "An image of a cat" = Parser.parse_image_prompt(response)
    end

    test "returns nil if the image_prompt key is not present" do
      response = make_json_message(%{text: "Hello, world!"})

      assert Parser.parse_image_prompt(response) |> is_nil()
    end

    test "returns nil if the message is not a JSON response" do
      response = %{
        role: "assistant",
        content: "Hello, world!"
      }

      assert Parser.parse_image_prompt(response) |> is_nil()
    end
  end

  defp make_json_message(%{role: role, content: content}) do
    %Message{
      role: role,
      content: Jason.encode!(content)
    }
  end

  defp make_json_message(response_json) do
    json = Jason.encode!(response_json)

    %Message{
      role: "assistant",
      content: json
    }
  end
end
