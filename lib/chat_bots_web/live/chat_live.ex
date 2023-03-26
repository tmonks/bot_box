defmodule ChatBotsWeb.ChatLive do
  use ChatBotsWeb, :live_view
  alias ChatBots.Bots
  alias ChatBots.Chats

  def mount(_params, _session, socket) do
    bots = Bots.list_bots()
    bot = hd(bots)
    chat = Chats.new_chat(bot.id)

    socket =
      socket
      |> assign(:bots, bots)
      |> assign(:bot, bot)
      |> assign(:chat, chat)

    {:ok, socket}
  end

  def handle_event("send_message", %{"message" => message_text}, socket) do
    # chat = Chats.add_message(socket.assigns.chat, %{role: "user", content: message})

    {:ok, chat} = ChatBots.ChatApi.send_message(socket.assigns.chat, message_text)

    {:noreply, assign(socket, chat: chat)}
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
    <!-- chat form with textarea to enter message -->
    <form id="chat-form" phx-submit="send_message">
      <textarea
        id="message"
        name="message"
        class="w-full h-24 p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
      >
      </textarea>
      <button type="submit" class="w-full mt-2 btn btn-primary">Send</button>
    </form>
    <!-- chat box to display messages -->
    <div id="chat-box">
      <%= for message <- @chat.messages do %>
        <%= if message.role != "system" do %>
          <p class="p-2 m-2 text-gray-800 bg-gray-200 rounded-md">
            <%= message.role %>: <%= message.content %>
          </p>
        <% end %>
      <% end %>
    </div>
    """
  end
end
