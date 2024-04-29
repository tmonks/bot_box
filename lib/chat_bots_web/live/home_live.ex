defmodule ChatBotsWeb.HomeLive do
  use ChatBotsWeb, :live_view
  alias ChatBots.Bots
  alias ChatBots.Chats
  alias Timex.Format.DateTime.Formatters.Relative

  @impl true
  def mount(_params, _session, socket) do
    chats = Chats.list_chats()
    bots = Bots.list_bots()

    {:ok, assign(socket, chats: chats, bots: bots)}
  end

  @impl true
  def handle_event("new_chat", %{"bot_id" => bot_id}, socket) do
    bot = Bots.get_bot(bot_id)
    chat = Chats.create_chat(bot)
    socket = push_navigate(socket, to: ~p"/chat/#{chat.id}")

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="mt-0 mb-2 text-4xl font-medium leading-tight text-primary">
        Bot Box
      </div>
      <form id="bot-select-form" phx-submit="new_chat">
        <select
          id="bot-select"
          name="bot_id"
          class="block appearance-none w-full bg-white border border-gray-400 hover:border-gray-500 px-4 py-2 pr-8 rounded shadow leading-tight focus:outline-none focus:shadow-outline mb-2"
        >
          <%= options_for_select(bot_options(@bots), []) %>
        </select>
        <button class="bg-primary" type="submit">New Chat</button>
      </form>
      <%= for chat <- @chats do %>
        <div id={"chat-#{chat.id}"} class="flex flex-row items-center">
          <div>😃</div>
          <div class="flex flex-col">
            <div><%= chat.bot.name %></div>
            <div data-role="content"><%= chat.latest_message.content %></div>
          </div>
          <div data-role="time">
            <%= Relative.format!(chat.latest_message.inserted_at, "{relative}") %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp bot_options(bots), do: Enum.map(bots, &{&1.name, &1.id})
end
