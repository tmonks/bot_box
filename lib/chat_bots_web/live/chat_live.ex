defmodule ChatBotsWeb.ChatLive do
  use ChatBotsWeb, :live_view
  alias ChatBots.Bots

  def mount(_params, _session, socket) do
    bots = Bots.list_bots()
    socket = assign(socket, :bots, bots)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1 class="mt-0 mb-2 text-5xl font-medium leading-tight text-primary">
      Bot Box
    </h1>
    <select id="bot-select">
      <%= for bot <- @bots do %>
        <option><%= bot.name %></option>
      <% end %>
    </select>
    """
  end
end
