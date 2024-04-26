defmodule ChatBotsWeb.HomeLive do
  use ChatBotsWeb, :live_view
  alias ChatBots.Chats

  @impl true
  def mount(_params, _session, socket) do
    chats = Chats.list_chats()

    {:ok, assign(socket, chats: chats)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= for chat <- @chats do %>
        <div id={"chat-#{chat.id}"}>
          <%= chat.bot.name %>
        </div>
      <% end %>
    </div>
    """
  end
end
