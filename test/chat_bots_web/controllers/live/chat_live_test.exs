defmodule ChatBotsWeb.Test do
  use ChatBotsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the page", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")
    assert html =~ "Bot Box"
  end
end
