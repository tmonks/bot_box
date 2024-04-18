defmodule ChatBotsWeb.HomeLive do
  use ChatBotsWeb, :live_view

  alias ChatBots.Chats

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1>Chat List</h1>
      <ul>
        <li>Chat 1</li>
        <li>Chat 2</li>
        <li>Chat 3</li>
      </ul>
    </div>
    """
  end
end
