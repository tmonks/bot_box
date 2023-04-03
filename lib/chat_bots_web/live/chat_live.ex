defmodule ChatBotsWeb.ChatLive do
  use ChatBotsWeb, :live_view
  alias ChatBots.Bots
  alias ChatBots.Chats

  def mount(_params, _session, socket) do
    bots = Bots.list_bots()
    bot = hd(bots)
    chat = Chats.new_chat(bot.id)
    messages = [%{role: "info", content: "#{bot.name} has entered the chat"}]

    socket =
      socket
      |> assign(:bots, bots)
      |> assign(:bot, bot)
      |> assign(:chat, chat)
      |> assign(:messages, messages)
      |> assign(:loading, false)

    {:ok, socket}
  end

  def handle_event("select_bot", %{"bot_id" => bot_id}, socket) do
    bot = Bots.get_bot(bot_id)
    chat = Chats.new_chat(bot.id)
    messages = [%{role: "info", content: "#{bot.name} has entered the chat"}]

    socket =
      socket
      |> assign(:bot, bot)
      |> assign(:chat, chat)
      |> assign(:messages, messages)

    {:noreply, socket}
  end

  def handle_event("submit_message", %{"message" => message_text}, socket) do
    send(self(), {:send_message, message_text})

    # add user message to messages
    user_message = %{role: "user", content: message_text}
    messages = socket.assigns.messages ++ [user_message]

    socket = assign(socket, messages: messages, loading: true)
    {:noreply, socket}
  end

  def handle_info({:send_message, message_text}, socket) do
    {:ok, chat} = ChatBots.ChatApi.send_message(socket.assigns.chat, message_text)
    bot_message = chat.messages |> List.last()
    messages = socket.assigns.messages ++ [bot_message]

    socket = assign(socket, chat: chat, messages: messages, loading: false)
    {:noreply, socket}
  end

  defp format_message(%{role: role, content: message_text}, bot) do
    case role do
      "assistant" -> "#{bot.name}: #{message_text}"
      "user" -> "You: #{message_text}"
      _ -> message_text
    end
  end

  def render(assigns) do
    ~H"""
    <h1 class="mt-0 mb-2 text-5xl font-medium leading-tight text-primary">
      Bot Box
    </h1>
    <form id="bot-select-form" phx-change="select_bot">
      <select
        id="bot-select"
        name="bot_id"
        class="block appearance-none w-full bg-white border border-gray-400 hover:border-gray-500 px-4 py-2 pr-8 rounded shadow leading-tight focus:outline-none focus:shadow-outline mb-2"
      >
        <%= for bot <- @bots do %>
          <option value={bot.id}><%= bot.name %></option>
        <% end %>
      </select>
    </form>
    <!-- chat box to display messages -->
    <div id="chat-box" class="flex flex-col">
      <%= for message <- @messages do %>
        <p class={get_message_classes(message)}>
          <%= format_message(message, @bot) %>
        </p>
      <% end %>
    </div>
    <!-- loading animation -->
    <%= if @loading do %>
      <div class="loader">Loading...</div>
    <% end %>
    <!-- chat form with textarea to enter message -->
    <form id="chat-form" phx-submit="submit_message">
      <div class="flex items-center space-x-4 p-2">
        <textarea
          id="message"
          name="message"
          rows="1"
          placeholder="Type a messsage..."
          class="flex-grow bg-white border border-gray-300 rounded-lg p-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
        </textarea>
        <button
          type="submit"
          class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
        >
          Send
        </button>
      </div>
    </form>
    """
  end

  defp get_message_classes(message) do
    base_classes = "p-2 my-2 rounded-lg text-sm w-auto max-w-sm"

    case message.role do
      "user" ->
        "#{base_classes} text-white bg-blue-500 self-end"

      _ ->
        "#{base_classes} text-gray-800 bg-gray-300"
    end
  end
end
