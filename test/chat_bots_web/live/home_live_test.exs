defmodule ChatBotsWeb.HomeLiveTest do
  use ChatBotsWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import ChatBots.Factory
  alias ChatBots.Chats.Chat
  alias ChatBots.Repo

  setup :login_user

  test "lists existing chats", %{conn: conn} do
    chat = insert(:chat)
    insert(:message, chat: chat)
    {:ok, view, _html} = live(conn, "/")

    assert has_element?(view, "#chat-#{chat.id}")
  end

  test "shows the bot's name for each chat", %{conn: conn} do
    bot = insert(:bot, name: "Bob")
    chat = insert(:chat, bot: bot)
    insert(:message, chat: chat)
    {:ok, view, _html} = live(conn, "/")

    assert has_element?(view, "#chat-#{chat.id}", "Bob")
  end

  test "shows the relative time of the last message on each chat", %{conn: conn} do
    chat = insert(:chat)
    insert(:message, chat: chat, inserted_at: Timex.now() |> Timex.shift(minutes: -5))

    {:ok, view, _html} = live(conn, "/")

    assert has_element?(
             view,
             "#chat-#{chat.id} div[data-role=time]",
             "5 minutes ago"
           )
  end

  test "shows an excerpt of the last message on each chat", %{conn: conn} do
    chat = insert(:chat)
    insert(:message, chat: chat, content: "Some witty message")

    {:ok, view, _html} = live(conn, "/")

    assert has_element?(
             view,
             "#chat-#{chat.id} div[data-role=content]",
             "Some witty message"
           )
  end

  test "redirects to ChatLive when a chat is clicked", %{conn: conn} do
    chat = insert(:chat)
    insert(:message, chat: chat, content: "Hello")

    {:ok, view, _html} = live(conn, "/")

    view
    |> element("#chat-#{chat.id}")
    |> render_click()
    |> follow_redirect(conn, ~p"/chat/#{chat.id}")

    # assert redirected_to(view, ~p"/chat/#{chat.id}")
  end

  test "includes a drop-down list of bots to start a chat with", %{conn: conn} do
    insert(:bot, name: "BobBot")
    {:ok, view, _html} = live(conn, "/")

    assert has_element?(view, "#bot-select")
    assert has_element?(view, "#bot-select option", "BobBot")
    assert has_element?(view, "#bot-select-form button", "New Chat")
  end

  test "can create a new chat and redirect to it", %{conn: conn} do
    _bot1 = insert(:bot, name: "Bot 1")
    bot2 = %{id: bot2_id} = insert(:bot, name: "Bot 2")
    {:ok, view, _html} = live(conn, "/")

    redirect =
      view
      |> form("#bot-select-form", %{"bot_id" => bot2.id})
      |> render_submit()

    assert {:error, {:live_redirect, %{to: redirect_url}}} = redirect
    assert redirect_url =~ "/chat/"
    chat_id = redirect_url |> String.split("/") |> List.last()
    assert %{bot_id: ^bot2_id} = Repo.get!(Chat, chat_id)
  end
end
