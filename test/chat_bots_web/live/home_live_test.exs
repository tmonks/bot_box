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

    assert has_element?(view, "#chat-#{chat.id}", "Bob")
  end

  test "shows the relative time of the last message on each chat", %{conn: conn} do
    chat = insert(:chat)
    message = insert(:message, chat: chat, inserted_at: Timex.now() |> Timex.shift(minutes: -5))

    {:ok, view, _html} = live(conn, "/")

    assert has_element?(
             view,
             "#chat-#{chat.id} div[data-role=time]",
             "5 minutes ago"
           )
  end

  test "shows an excerpt of the last message on each chat", %{conn: conn} do
  end
end
