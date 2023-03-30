defmodule ChatBotsWeb.Test do
  use ChatBotsWeb.ConnCase, async: true
  import Mox
  import ChatBots.Fixtures
  import Phoenix.LiveViewTest
  alias ChatBots.OpenAi.MockClient

  setup :verify_on_exit!

  test "renders the page", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")
    assert html =~ "Bot Box"
  end

  test "has a select to choose the bot", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert has_element?(view, "#bot-select")
    assert has_element?(view, "#bot-select option", "Test Bot")
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

    expect_api_success(message_text)

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert has_element?(view, "#chat-box p", ~r/Test Bot.*42/)
  end

  test "doesn't display system prompt", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    refute html =~ "You are a helpful assistant"
  end

  test "displays a user-friendly role title for each message", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    message_text = "Hello Bot"

    expect_api_success(message_text)

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert has_element?(view, "#chat-box p", ~r/You.*Hello Bot/)
    assert has_element?(view, "#chat-box p", ~r/Test Bot.*42/)
  end

  test "displays welcome message", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert has_element?(view, "#chat-box p", ~r/Test Bot has entered the chat/)
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
