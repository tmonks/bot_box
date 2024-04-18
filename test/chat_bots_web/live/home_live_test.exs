defmodule ChatBotsWeb.HomeLiveTest do
  use ChatBotsWeb.ConnCase
  import Phoenix.LiveViewTest

  test "lists existing chats", %{conn: conn} do
    chat = insert(:chat)
    {:ok, view, _html} = live(conn, "/")

    assert has_element?(view, "#chat-#{chat.id}")
  end
end
