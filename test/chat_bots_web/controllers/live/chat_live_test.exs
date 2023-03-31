defmodule ChatBotsWeb.Test do
  use ChatBotsWeb.ConnCase, async: true
  import Mox
  import ChatBots.Fixtures
  import Phoenix.LiveViewTest
  alias ChatBots.OpenAi.MockClient
  alias ChatBots.Bots

  setup :verify_on_exit!

  test "renders the page", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")
    assert html =~ "Bot Box"
  end

  test "has a select to choose the bot", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    bot = Bots.list_bots() |> List.first()

    assert has_element?(view, "#bot-select")
    assert has_element?(view, "#bot-select option", bot.name)
  end

  test "can enter a message and see it appear in the chat", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    message_text = "Hello Bot"

    refute has_element?(view, "#chat-box p", message_text)

    expect_api_success(message_text)

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert has_element?(view, "#chat-box p", ~r/You.*Hello Bot/)
  end

  test "can receive and view a response from the bot", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    message_text = "Hello Bot"
    bot = Bots.list_bots() |> List.first()

    expect_api_success(message_text)

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert has_element?(view, "#chat-box p", ~r/#{bot.name}.*42/)
  end

  test "doesn't display system prompt", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    refute html =~ "You are a helpful assistant"
  end

  test "displays a user-friendly role title for each message", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    bot = Bots.list_bots() |> List.first()
    message_text = "Hello Bot"

    expect_api_success(message_text)

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert has_element?(view, "#chat-box p", ~r/You.*Hello Bot/)
    assert has_element?(view, "#chat-box p", ~r/#{bot.name}.*42/)
  end

  test "displays welcome message", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    bot = Bots.list_bots() |> List.first()

    assert has_element?(view, "#chat-box p", ~r/#{bot.name} has entered the chat/)
  end

  test "selecting a different bot clears the chat", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    bots = Bots.list_bots()
    bot1 = bots |> List.first()
    bot2 = bots |> Enum.at(1)

    message_text = "Hello Bot"

    expect_api_success(message_text)

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert has_element?(view, "#chat-box p", ~r/You.*Hello Bot/)
    assert has_element?(view, "#chat-box p", ~r/#{bot1.name}.*42/)
    assert has_element?(view, "#chat-box p", ~r/#{bot1.name} has entered the chat/)

    view
    |> form("#bot-select-form", %{"bot_id" => bot2.id})
    |> render_change()

    refute has_element?(view, "#chat-box p", ~r/You.*Hello Bot/)
    refute has_element?(view, "#chat-box p", ~r/#{bot1.name}.*42/)
    refute has_element?(view, "#chat-box p", ~r/#{bot1.name} has entered the chat/)
    assert has_element?(view, "#chat-box p", ~r/#{bot2.name} has entered the chat/)
  end

  test "displays error message returned by the API", %{conn: _conn} do
  end

  # Set up the mock and assert the message is sent to the client with message_text
  defp expect_api_success(message_sent) do
    MockClient
    |> expect(:chat_completion, fn [model: _, messages: messages] ->
      assert [_, user_message] = messages
      assert user_message == %{role: "user", content: message_sent}
      api_success_fixture()
    end)
  end
end
