defmodule ChatBotsWeb.ChatLive do
  use ChatBotsWeb, :live_view
  alias ChatBots.Bots
  alias ChatBots.Chats
  alias ChatBots.Chats.Bubble
  alias ChatBots.Chats.Image
  alias ChatBots.Chats.Message
  alias ChatBots.OpenAi.Api, as: ChatApi
  alias ChatBots.StabilityAi.Api, as: ImageApi
  alias ChatBots.Parser

  def mount(_params, _session, socket) do
    bots = Bots.list_bots()
    bot = hd(bots)

    socket =
      socket
      |> assign(:bots, bots)
      |> assign_messages_and_bot(bot)
      |> assign(:loading, false)

    {:ok, socket}
  end

  def handle_event("select_bot", %{"bot_id" => bot_id}, socket) do
    bot = Bots.get_bot(bot_id)
    socket = assign_messages_and_bot(socket, bot)

    {:noreply, socket}
  end

  def handle_event("submit_message", %{"message" => message_text}, socket) do
    # send a message to self to trigger the API call in the background
    send(self(), :request_chat)

    # add user message to messages
    messages =
      Chats.add_message(socket.assigns.messages, %Message{role: "user", content: message_text})

    socket = assign(socket, messages: messages, loading: true)
    {:noreply, socket}
  end

  defp assign_messages_and_bot(socket, bot) do
    messages =
      Chats.new_chat(bot.id)
      |> Chats.add_message(%Message{role: "info", content: "#{bot.name} has entered the chat"})

    assign(socket, messages: messages, bot: bot)
  end

  def handle_info(:request_chat, socket) do
    filtered_messages = filter_messages_for_api(socket.assigns.messages)

    case ChatApi.send_message(filtered_messages) do
      {:ok, message} ->
        messages = Chats.add_message(socket.assigns.messages, message)

        {:noreply,
         socket
         |> assign(messages: messages, loading: false)
         |> maybe_send_image_request()}

      {:error, error} ->
        messages =
          Chats.add_message(socket.assigns.messages, %Message{
            role: "error",
            content: error["message"]
          })

        {:noreply, assign(socket, messages: messages, loading: false)}
    end
  end

  def handle_info({:request_image, image_prompt}, socket) do
    {:ok, file} = ImageApi.generate_image(image_prompt)
    image_attrs = %{file: file, prompt: image_prompt}
    image_message = %{role: "image", content: Jason.encode!(image_attrs)}
    messages = Chats.add_message(socket.assigns.messages, image_message)
    {:noreply, assign(socket, messages: messages, loading: false)}
  end

  defp convert_messages_to_chat_items(messages) do
    messages
    |> Enum.filter(&(&1.role != "system"))
    |> Enum.flat_map(&Parser.parse(&1))
  end

  defp filter_messages_for_api(messages) do
    messages
    |> Enum.filter(&(&1.role in ["system", "user", "assistant"]))
  end

  defp maybe_send_image_request(socket) do
    # check the latest message for an image prompt
    image_prompt = socket.assigns.messages |> List.last() |> Parser.parse_image_prompt()

    case image_prompt do
      nil ->
        socket

      _ ->
        send(self(), {:request_image, image_prompt})
        assign(socket, loading: true)
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
        <%= options_for_select(bot_options(@bots), @bot.id) %>
      </select>
    </form>
    <!-- chat box to display chat_items -->
    <div id="chat-box" class="flex flex-col">
      <%= for chat_item <- convert_messages_to_chat_items(@messages) do %>
        <.render_chat_item item={chat_item} />
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

  defp render_chat_item(%{item: %Bubble{type: "error"}} = assigns) do
    ~H"""
    <p class={get_message_classes(@item.type)}>Error: <%= @item.text %></p>
    """
  end

  defp render_chat_item(%{item: %Bubble{}} = assigns) do
    ~H"""
    <p class={get_message_classes(@item.type)}><%= @item.text %></p>
    """
  end

  defp render_chat_item(%{item: %Image{}} = assigns) do
    ~H"""
    <div class="chat-image">
      <%= if is_nil(@item.file) do %>
        <span>loading...</span>
      <% else %>
        <img style="width: 512px" src={"/images/" <> @item.file} />
      <% end %>
    </div>
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
