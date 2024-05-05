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
              <div class="w-48"><.bot_icon /></div>
              <div class="flex flex-col">
                <div class="text-lg font-bold"><%= chat.bot.name %></div>
                <div class="text-sm font-light" data-role="content">
                  <%= chat.latest_message.content %>
                </div>
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

  defp bot_icon(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="currentColor"
      class="w-full h-full text-blue-500"
    >
      <path
        fill-rule="evenodd"
        d="M18.685 19.097A9.723 9.723 0 0 0 21.75 12c0-5.385-4.365-9.75-9.75-9.75S2.25 6.615 2.25 12a9.723 9.723 0 0 0 3.065 7.097A9.716 9.716 0 0 0 12 21.75a9.716 9.716 0 0 0 6.685-2.653Zm-12.54-1.285A7.486 7.486 0 0 1 12 15a7.486 7.486 0 0 1 5.855 2.812A8.224 8.224 0 0 1 12 20.25a8.224 8.224 0 0 1-5.855-2.438ZM15.75 9a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0Z"
        clip-rule="evenodd"
      />
    </svg>
    """
  end

  defp bot_options(bots), do: Enum.map(bots, &{&1.name, &1.id})
end
