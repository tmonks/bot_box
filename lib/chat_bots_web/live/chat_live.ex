defmodule ChatBotsWeb.ChatLive do
  use ChatBotsWeb, :live_view
  alias ChatBots.Bots
  alias ChatBots.Chats
  alias ChatBots.Chats.Bubble
  alias ChatBots.Parser

  def mount(_params, _session, socket) do
    bots = Bots.list_bots()
    bot = hd(bots)
    chat = Chats.new_chat(bot.id)
    chat_items = [%Bubble{type: "info", text: "#{bot.name} has entered the chat"}]

    socket =
      socket
      |> assign(:bots, bots)
      |> assign(:bot, bot)
      |> assign(:chat, chat)
      |> assign(:chat_items, chat_items)
      |> assign(:loading, false)

    {:ok, socket}
  end

  def handle_event("select_bot", %{"bot_id" => bot_id}, socket) do
    bot = Bots.get_bot(bot_id)
    chat = Chats.new_chat(bot.id)
    chat_items = [%{type: "info", text: "#{bot.name} has entered the chat"}]

    socket =
      socket
      |> assign(:bot, bot)
      |> assign(:chat, chat)
      |> assign(:chat_items, chat_items)

    {:noreply, socket}
  end

  def handle_event("submit_message", %{"message" => message_text}, socket) do
    # send a message to self to trigger the API call in the background
    send(self(), {:send_message, message_text})

    # add user message to chat_items
    user_message = %Bubble{type: "user", text: message_text}
    chat_items = socket.assigns.chat_items ++ [user_message]

    socket = assign(socket, chat_items: chat_items, loading: true)
    {:noreply, socket}
  end

  def handle_info({:send_message, message_text}, socket) do
    socket =
      case ChatBots.ChatApi.send_message(socket.assigns.chat, message_text) do
        {:ok, chat} ->
          bubble = chat.messages |> List.last() |> Parser.parse()
          chat_items = socket.assigns.chat_items ++ [bubble]
          assign(socket, chat: chat, chat_items: chat_items, loading: false)

        {:error, error} ->
          chat_items =
            socket.assigns.chat_items ++ [%Bubble{type: "error", text: error["message"]}]

          assign(socket, chat_items: chat_items, loading: false)
      end

    {:noreply, socket}
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
        <%= options_for_select(bot_options(@bots), @bot.id) %>
      </select>
    </form>
    <!-- chat box to display chat_items -->
    <div id="chat-box" class="flex flex-col">
      <%= for chat_item <- @chat_items do %>
        <%= for line <- String.split(chat_item.text, "\n\n") do %>
          <.message_bubble type={chat_item.type} text={line} />
        <% end %>
      <% end %>
    </div>
    <!-- loading animation -->
    <%= if @loading do %>
      <div class="loader">Loading...</div>
    <% end %>
    <!-- chat form with textarea to enter message -->
    <form id="chat-form" phx-submit="submit_message">
      <div class="flex items-center space-x-4 pt-2">
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

  defp message_bubble(%{type: "error"} = assigns) do
    ~H"""
    <p class={get_message_classes(@type)}>Error: <%= @text %></p>
    """
  end

  defp message_bubble(assigns) do
    ~H"""
    <p class={get_message_classes(@type)}><%= @text %></p>
    """
  end

  defp get_message_classes(type) do
    base_classes = "p-2 my-2 rounded-lg text-sm w-auto max-w-md"

    case type do
      "user" ->
        "#{base_classes} user-bubble text-white bg-blue-500 self-end"

      _ ->
        "#{base_classes} bot-bubble text-gray-800 bg-gray-300"
    end
  end

  defp bot_options(bots), do: Enum.map(bots, &{&1.name, &1.id})
end
