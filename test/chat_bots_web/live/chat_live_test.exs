defmodule ChatBotsWeb.ChatLiveTest do
  use ChatBotsWeb.ConnCase, async: false
  import Mox
  import ChatBots.Factory
  import ChatBots.Fixtures
  import ChatBots.Fixtures.StabilityAiFixtures
  import Phoenix.LiveViewTest

  alias ChatBots.OpenAi.MockClient, as: OpenAiMock
  alias ChatBots.Repo
  alias ChatBots.StabilityAi.MockClient, as: StabilityAiMock

  setup :verify_on_exit!
  setup :login_user

  test "returns 401 when not logged in", %{conn: conn} do
    chat = insert(:chat)

    conn =
      conn
      |> delete_req_header("authorization")
      |> get("/chat/#{chat.id}")

    assert response(conn, 401)
  end

  test "loads a chat from the database", %{conn: conn} do
    chat = insert(:chat, messages: [%{role: "info", content: "Welcome to Bot Box"}])

    {:ok, _view, html} = live(conn, "/chat/#{chat.id}")
    assert html =~ "Welcome to Bot Box"
  end

  test "can enter a message and see it appear in the chat", %{conn: conn} do
    chat = insert(:chat)
    {:ok, view, _html} = live(conn, "/chat/#{chat.id}")

    message_text = "Hello!"

    refute has_element?(view, "#chat-box p", message_text)

    expect_chat_api_call(message_text)

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert has_element?(view, "#chat-box p.user-bubble", ~r/Hello!/)
    chat = Repo.reload(chat) |> Repo.preload(:messages)
    assert chat.messages |> Enum.any?(&(&1.role == "user" && &1.content == "Hello!"))
  end

  test "can receive and view a response from the bot", %{conn: conn} do
    chat = insert(:chat)
    {:ok, view, _html} = live(conn, "/chat/#{chat.id}")

    message_text = "I am a user"

    expect_chat_api_call(message_text, "I am a bot")

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert has_element?(view, "#chat-box p.bot-bubble", ~r/I am a bot/)
  end

  test "doesn't display system prompt", %{conn: conn} do
    chat = insert(:chat, messages: [%{role: "system", content: "You are a helpful assistant"}])
    {:ok, _view, html} = live(conn, "/chat/#{chat.id}")

    refute html =~ "You are a helpful assistant"
  end

  test "doesn't display ImageRequests", %{conn: conn} do
    chat = insert(:chat)

    insert(:message,
      chat: chat,
      role: "assistant",
      content: Jason.encode!(%{image_prompt: "A picture of a cat"})
    )

    {:ok, _view, html} = live(conn, "/chat/#{chat.id}")

    refute html =~ "A picture of a cat"
  end

  test "displays a user-friendly role title for each message", %{conn: conn} do
    chat = insert(:chat)
    {:ok, view, _html} = live(conn, "/chat/#{chat.id}")

    message_text = "I am a user"

    expect_chat_api_call(message_text, "I am a bot")

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert has_element?(view, "#chat-box p.user-bubble", ~r/I am a user/)
    assert has_element?(view, "#chat-box p.bot-bubble", ~r/I am a bot/)
  end

  @tag :skip
  test "displays welcome message", %{conn: conn} do
    bot = insert(:bot, name: "Bob Bot")
    chat = insert(:chat, bot: bot)
    {:ok, view, _html} = live(conn, "/chat/#{chat.id}")

    assert has_element?(view, "#chat-box p", ~r/Bob Bot has entered the chat/)
  end

  test "does not send 'info' messages to the API", %{conn: conn} do
    chat = insert(:chat)
    {:ok, view, _html} = live(conn, "/chat/#{chat.id}")

    OpenAiMock
    |> expect(:chat_completion, fn [model: _, messages: messages] ->
      assert not Enum.any?(messages, &(&1.role == "info"))
      assert %{role: "user", content: "Hello bot"} in messages
      api_success_fixture("Hello human")
    end)

    view
    |> form("#chat-form", %{"message" => "Hello bot"})
    |> render_submit()

    :timer.sleep(100)
  end

  test "displays error message returned by the API in the chat area", %{conn: conn} do
    chat = insert(:chat)
    {:ok, view, _html} = live(conn, "/chat/#{chat.id}")

    OpenAiMock
    |> expect(:chat_completion, fn _ -> api_error_fixture() end)

    view
    |> form("#chat-form", %{"message" => "Hello"})
    |> render_submit()

    assert has_element?(view, "#chat-box p", ~r/Error.*Invalid request/)
    chat = Repo.preload(chat, :messages)
    assert chat.messages |> Enum.any?(&(&1.role == "error"))
  end

  test "breaks up mult-line responses into multiple chat bubbles", %{conn: conn} do
    chat = insert(:chat)
    {:ok, view, _html} = live(conn, "/chat/#{chat.id}")

    message_text = "Hello"
    expect_chat_api_call(message_text, "first line\n\nsecond line")

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert has_element?(view, "p.bot-bubble", ~r"\Afirst line\z")
    assert has_element?(view, "p.bot-bubble", ~r"\Asecond line\z")
  end

  @tag :skip
  test "displays an Image response as loading", %{conn: conn} do
    chat = insert(:chat)
    {:ok, view, _html} = live(conn, "/chat/#{chat.id}")

    message_text = "Make a picture of a cat"

    expect_chat_api_call(message_text, %{
      text: "here is your picture",
      image_prompt: "A picture of a cat"
    })

    expect_image_api_call("A picture of a cat")

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert has_element?(view, ".chat-image", "loading")
  end

  @tag :skip
  test "displays an Image after the new Bubble", %{conn: conn} do
    chat = insert(:chat)
    {:ok, view, _html} = live(conn, "/chat/#{chat.id}")

    message_text = "Make a picture of a cat"

    expect_chat_api_call(message_text, %{
      text: "here is your picture",
      image_prompt: "A picture of a cat"
    })

    expect_image_api_call("A picture of a cat")

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert render(view) =~ ~r"here is your picture.*chat-image"
    :timer.sleep(100)
  end

  test "displays image prompts from the API", %{conn: conn} do
    chat = insert(:chat)
    {:ok, view, _html} = live(conn, "/chat/#{chat.id}")

    message_text = "Make a picture of a cat"

    chat_response = %{
      text: "here is your picture",
      image_prompt: "A picture of a cat"
    }

    expect_chat_api_call(message_text, chat_response)
    expect_image_api_call("A picture of a cat")

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert has_element?(view, "p.bot-bubble", ~r/here is your picture/)
    assert has_element?(view, "p.bot-bubble", ~r/A picture of a cat/)
  end

  test "displays a Choice as a list of buttons", %{conn: conn} do
    chat = insert(:chat)
    {:ok, view, _html} = live(conn, "/chat/#{chat.id}")

    message_text = "What is your favorite color?"

    chat_response = %{
      text: "Choose a color",
      options: ["Red", "Green", "Blue"]
    }

    expect_chat_api_call(message_text, chat_response)

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert has_element?(view, "button", ~r/Red/)
    assert has_element?(view, "button", ~r/Green/)
    assert has_element?(view, "button", ~r/Blue/)
  end

  test "clicking a Choice button sends the option text to the API", %{conn: conn} do
    chat = insert(:chat)

    insert(:message,
      chat: chat,
      role: "assistant",
      content:
        Jason.encode!(%{
          text: "Choose a color",
          options: ["Red", "Green", "Blue"]
        })
    )

    {:ok, view, _html} = live(conn, "/chat/#{chat.id}")

    # "Red" gets sent to the API
    expect_chat_api_call("Red", "You chose Red")

    view
    |> element("button", "Red")
    |> render_click()

    # "Red" is displayed as a user message
    assert has_element?(view, "p.user-bubble", ~r/Red/)
  end

  test "sends image prompts to the StabilityAI API and displays the image returned", %{conn: conn} do
    chat = insert(:chat)
    {:ok, view, _html} = live(conn, "/chat/#{chat.id}")

    message_text = "Make a picture of a cat"

    chat_response = %{
      text: "here is your picture",
      image_prompt: "A picture of a cat"
    }

    expect_chat_api_call(message_text, chat_response)
    expect_image_api_call("A picture of a cat")

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    # TODO set up expectation blocking instead of sleeping
    :timer.sleep(100)

    file_name = expected_file_name(12345)

    assert has_element?(view, "img[src='/images/#{file_name}']")

    chat = Repo.preload(chat, :messages)
    assert chat.messages |> Enum.any?(&(&1.role == "image"))
  end

  # Set up the mock and assert the message is sent to the client with message_text
  defp expect_chat_api_call(message_sent, message_received \\ "42") do
    OpenAiMock
    |> expect(:chat_completion, fn [model: _, messages: messages] ->
      assert %{role: "user", content: ^message_sent} = List.last(messages)
      api_success_fixture(message_received)
    end)
  end

  defp expect_image_api_call(image_prompt) do
    StabilityAiMock
    |> expect(:post, fn _url, options ->
      %{text_prompts: text_prompts} = Keyword.get(options, :json)
      assert %{text: image_prompt, weight: 1} in text_prompts

      {:ok, %Req.Response{body: %{"artifacts" => [%{"base64" => "Zm9vYmFy", "seed" => 12345}]}}}
    end)
  end
end
