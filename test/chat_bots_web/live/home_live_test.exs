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

  test "displays the image description when an image was the latest message", %{conn: conn} do
    chat = insert(:chat)

    insert(:message,
      chat: chat,
      role: "image",
      content: Jason.encode!(%{file: "filename.jpg", prompt: "A picture of a cat"})
    )

    {:ok, _view, html} = live(conn, "/")

    assert element_text(html, "#chat-#{chat.id} div[data-role=content]") == "A picture of a cat"
  end

  test "displays the image prompt when an image request was the latest message", %{conn: conn} do
    chat = insert(:chat)

    insert(:message,
      chat: chat,
      role: "assistant",
      content: Jason.encode!(%{image_prompt: "A picture of a cat"})
    )

    {:ok, _view, html} = live(conn, "/")

    assert element_text(html, "#chat-#{chat.id} div[data-role=content]") ==
             "A picture of a cat"
  end

  test "displays options when a Choice was the latest message", %{conn: conn} do
    chat = insert(:chat)

    insert(:message,
      chat: chat,
      role: "assistant",
      content: Jason.encode!(%{options: ["Option 1", "Option 2"]})
    )

    {:ok, _view, html} = live(conn, "/")

    assert element_text(html, "#chat-#{chat.id} div[data-role=content]") ==
             "Option 1, Option 2"
  end

  test "displays message text when a normal message was the last message", %{conn: conn} do
    chat = insert(:chat)

    insert(:message,
      chat: chat,
      role: "assistant",
      content: "Hello there!"
    )

    {:ok, _view, html} = live(conn, "/")

    assert element_text(html, "#chat-#{chat.id} div[data-role=content]") ==
             "Hello there!"
  end

  test "displays '(no messages yet)' if the sytem prompt is the only message", %{conn: conn} do
    chat = insert(:chat)

    insert(:message,
      chat: chat,
      role: "system",
      content: "You are a helpful bot"
    )

    {:ok, _view, html} = live(conn, "/")

    assert element_text(html, "#chat-#{chat.id} div[data-role=content]") ==
             "(no messages yet)"
  end

  defp element_text(html, dom_id) do
    html
    |> Floki.parse_document!()
    |> Floki.find(dom_id)
    |> Floki.text()
    |> String.trim()
  end
end
