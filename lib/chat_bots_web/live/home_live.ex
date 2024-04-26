defmodule ChatBotsWeb.HomeLive do
  use ChatBotsWeb, :live_view
  alias ChatBots.Chats
  alias Timex.Format.DateTime.Formatters.Relative

  @impl true
  def mount(_params, _session, socket) do
    chats = Chats.list_chats()

    {:ok, assign(socket, chats: chats)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="mt-0 mb-2 text-4xl font-medium leading-tight text-primary">
        Bot Box
      </div>
      <%= for chat <- @chats do %>
        <div id={"chat-#{chat.id}"} class="flex flex-row items-center">
          <div>😃</div>
          <div class="flex flex-col">
            <div><%= chat.bot.name %></div>
            <div>Message text here</div>
          </div>
          <div data-role="time">
            <%= Relative.format!(chat.latest_message.inserted_at, "{relative}") %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
