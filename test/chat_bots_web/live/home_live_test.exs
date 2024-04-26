defmodule ChatBotsWeb.HomeLiveTest do
  use ChatBotsWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import ChatBots.Factory

  setup :login_user

  test "lists existing chats", %{conn: conn} do
    chat = insert(:chat)
    {:ok, view, _html} = live(conn, "/")

    assert has_element?(view, "#chat-#{chat.id}")
  end

  test "shows the bot's name for each chat", %{conn: conn} do
    bot = insert(:bot, name: "Bob")
    chat = insert(:chat, bot: bot)
    {:ok, view, _html} = live(conn, "/")

    open_browser(view)

    assert has_element?(view, "#chat-#{chat.id}", "Bob")
  end
end
