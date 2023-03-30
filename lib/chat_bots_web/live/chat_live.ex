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

    {:ok, socket}
  end

  def handle_event("send_message", %{"message" => message_text}, socket) do
    # chat = Chats.add_message(socket.assigns.chat, %{role: "user", content: message})
    user_message = %{role: "user", content: message_text}

    {:ok, chat} = ChatBots.ChatApi.send_message(socket.assigns.chat, message_text)
    bot_message = chat.messages |> List.last()
    messages = socket.assigns.messages ++ [user_message, bot_message]

    socket = assign(socket, chat: chat, messages: messages)
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
    <select
      id="bot-select"
      class="block appearance-none w-full bg-white border border-gray-400 hover:border-gray-500 px-4 py-2 pr-8 rounded shadow leading-tight focus:outline-none focus:shadow-outline mb-2"
    >
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
      <button
        type="submit"
        class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
      >
        Send
      </button>
    </form>
    <!-- chat box to display messages -->
    <div id="chat-box">
      <%= for message <- @messages do %>
        <p class="p-2 m-2 text-gray-800 bg-gray-200 rounded-md">
          <%= format_message(message, @bot) %>
        </p>
      <% end %>
    </div>
    """
  end
end
