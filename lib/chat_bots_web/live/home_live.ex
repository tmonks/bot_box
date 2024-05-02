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
        <div class="flex gap-4 items-center mb-4">
          <select
            id="bot-select"
            name="bot_id"
            class="flex-auto block appearance-none bg-white border border-gray-400 hover:border-gray-500 px-4 py-2 pr-8 rounded shadow leading-tight focus:outline-none focus:shadow-outline"
          >
            <%= options_for_select(bot_options(@bots), []) %>
          </select>
          <button
            class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
            type="submit"
          >
            New Chat
          </button>
        </div>
      </form>
      <div class="flex flex-col gap-6">
        <%= for chat <- @chats do %>
          <.link navigate={~p"/chat/#{chat.id}"} id={"chat-#{chat.id}"}>
            <div class="flex flex-row items-center gap-4">
              <div class="w-32">😃</div>
              <div class="flex flex-col">
                <div class="text-lg font-bold"><%= chat.bot.name %></div>
                <div data-role="content"><%= chat.latest_message.content %></div>
              </div>
              <div class="w-80" data-role="time">
                <%= Relative.format!(chat.latest_message.inserted_at, "{relative}") %>
              </div>
            </div>
          </.link>
        <% end %>
      </div>
    </div>
    """
  end

  defp bot_options(bots), do: Enum.map(bots, &{&1.name, &1.id})
end
