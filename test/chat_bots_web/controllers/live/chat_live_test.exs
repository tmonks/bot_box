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

    # Set up the mock and assert the message is sent to the client as a map
    MockClient
    |> expect(:chat_completion, fn [model: _, messages: messages] ->
      assert [_, user_message] = messages
      assert user_message == %{role: "user", content: message_text}
      api_success_fixture()
    end)

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert has_element?(view, "#chat-box p", ~r/user.*Hello Bot/)
  end

  test "can receive and view a response from the bot", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    message_text = "Hello Bot"

    # Set up the mock and assert the message is sent to the client as a map
    MockClient
    |> expect(:chat_completion, fn [model: _, messages: messages] ->
      assert [_, user_message] = messages
      assert user_message == %{role: "user", content: message_text}
      api_success_fixture()
    end)

    view
    |> form("#chat-form", %{"message" => message_text})
    |> render_submit()

    assert has_element?(view, "#chat-box p", ~r/assistant.*42/)
  end

  test "doesn't display system prompt", %{conn: _conn} do
  end

  test "displays error message returned by the API", %{conn: _conn} do
  end
end
