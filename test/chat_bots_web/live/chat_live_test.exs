defmodule ChatBotsWeb.ChatLiveTest do
  use ChatBotsWeb.ConnCase, async: false
  import Mox
  import ChatBots.Fixtures
  import Phoenix.LiveViewTest
  alias ChatBots.OpenAi.MockClient, as: OpenAiMock
  alias ChatBots.StabilityAi.MockClient, as: StabilityAiMock

  setup :verify_on_exit!
  setup :login_user

  test "returns 401 when not logged in", %{conn: conn} do
    conn =
      conn
      |> delete_req_header("authorization")
      |> get("/")

    assert response(conn, 401)
  end

  test "renders the page", %{conn: conn} do
    _bot = bot_fixture()
    {:ok, _view, html} = live(conn, "/")
    assert html =~ "Bot Box"
  end

  test "has a select to choose the bot", %{conn: conn} do
    bot = bot_fixture()
    {:ok, view, _html} = live(conn, "/")

    assert has_element?(view, "#bot-select")
    assert has_element?(view, "#bot-select option", bot.name)
  end

  test "can enter a message and see it appear in the chat", %{conn: conn} do
    _bot = bot_fixture()
    {:ok, view, _html} = live(conn, "/")

    message_text = "Hello!"

    refute has_element?(view, "#chat-box p", message_text)

    expect_chat_api_call(message_text)

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert has_element?(view, "#chat-box p.user-bubble", ~r/Hello!/)
  end

  test "can receive and view a response from the bot", %{conn: conn} do
    bot_fixture()
    {:ok, view, _html} = live(conn, "/")

    message_text = "I am a user"

    expect_chat_api_call(message_text, "I am a bot")

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert has_element?(view, "#chat-box p.bot-bubble", ~r/I am a bot/)
  end

  test "doesn't display system prompt", %{conn: conn} do
    _bot = bot_fixture(%{name: "Test Bot", directive: "You are a helpful assistant"})
    {:ok, _view, html} = live(conn, "/")

    refute html =~ "You are a helpful assistant"
  end

  test "displays a user-friendly role title for each message", %{conn: conn} do
    bot_fixture()
    {:ok, view, _html} = live(conn, "/")

    message_text = "I am a user"

    expect_chat_api_call(message_text, "I am a bot")

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert has_element?(view, "#chat-box p.user-bubble", ~r/I am a user/)
    assert has_element?(view, "#chat-box p.bot-bubble", ~r/I am a bot/)
  end

  test "displays welcome message", %{conn: conn} do
    bot = bot_fixture()
    {:ok, view, _html} = live(conn, "/")

    assert has_element?(view, "#chat-box p", ~r/#{bot.name} has entered the chat/)
  end

  test "selecting a different bot clears the chat", %{conn: conn} do
    _bot1 = bot_fixture(name: "Bot 1", directive: "some directive 1")
    bot2 = bot_fixture(name: "Bot 2", directive: "some directive 2")
    {:ok, view, _html} = live(conn, "/")

    message_text = "I am a user"

    expect_chat_api_call(message_text, "I am a bot")

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert has_element?(view, "#chat-box p", ~r/Bot 1 has entered the chat/)
    assert has_element?(view, "#chat-box p.user-bubble", ~r/I am a user/)
    assert has_element?(view, "#chat-box p.bot-bubble", ~r/I am a bot/)

    view
    |> form("#bot-select-form", %{"bot_id" => bot2.id})
    |> render_change()

    refute has_element?(view, "#chat-box p", ~r/Bot 1 has entered the chat/)
    refute has_element?(view, "#chat-box p", ~r/I am a user/)
    refute has_element?(view, "#chat-box p", ~r/I am a bot/)
    assert has_element?(view, "#chat-box p", ~r/Bot 2 has entered the chat/)
  end

  test "retains selected bot", %{conn: conn} do
    _bot1 = bot_fixture(name: "Bot 1", directive: "some directive 1")
    bot2 = bot_fixture(name: "Bot 2", directive: "some directive 2")
    {:ok, view, _html} = live(conn, "/")

    view
    |> form("#bot-select-form", %{"bot_id" => bot2.id})
    |> render_change()

    assert has_element?(view, "#bot-select option[selected]", bot2.name)

    expect_chat_api_call("Hello")

    view
    |> form("#chat-form", %{"message" => "Hello"})
    |> render_submit()

    assert has_element?(view, "#bot-select option[selected]", bot2.name)
  end

  test "displays error message returned by the API in the chat area", %{conn: conn} do
    _bot = bot_fixture()

    {:ok, view, _html} = live(conn, "/")

    OpenAiMock
    |> expect(:chat_completion, fn _ -> api_error_fixture() end)

    view
    |> form("#chat-form", %{"message" => "Hello"})
    |> render_submit()

    assert has_element?(view, "#chat-box p", ~r/Error.*Invalid request/)
  end

  test "breaks up mult-line responses into multiple chat bubbles", %{conn: conn} do
    bot_fixture()
    {:ok, view, _html} = live(conn, "/")

    message_text = "Hello"
    expect_chat_api_call(message_text, "first line\n\nsecond line")

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert has_element?(view, "p.bot-bubble", ~r"\Afirst line\z")
    assert has_element?(view, "p.bot-bubble", ~r"\Asecond line\z")
  end

  test "displays an Image response as loading", %{conn: conn} do
    bot_fixture()
    {:ok, view, _html} = live(conn, "/")

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

  test "displays an Image after the new Bubble", %{conn: conn} do
    bot_fixture()
    {:ok, view, _html} = live(conn, "/")

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

  test "sends image prompts to the StabilityAI API", %{conn: conn} do
    bot_fixture()
    {:ok, view, _html} = live(conn, "/")

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
  end

  # Set up the mock and assert the message is sent to the client with message_text
  defp expect_chat_api_call(message_sent, message_received \\ "42") do
    OpenAiMock
    |> expect(:chat_completion, fn [model: _, messages: messages] ->
      assert [_, user_message] = messages
      assert user_message == %{role: "user", content: message_sent}
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
