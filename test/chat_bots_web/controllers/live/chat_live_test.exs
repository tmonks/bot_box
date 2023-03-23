defmodule ChatBotsWeb.Test do
  use ChatBotsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

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

    refute has_element?(view, "#chat-box p", "Hello Bot")

    view
    |> form("#chat-form", %{"message" => "Hello Bot"})
    |> render_submit()

    assert has_element?(view, "#chat-box p", "Hello Bot")
  end

  test "doesn't display system prompt", %{conn: conn} do
  end

  test "can receive and view a response from the bot", %{conn: conn} do
  end
end
