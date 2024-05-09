defmodule ChatBotsWeb.ChatLive do
  use ChatBotsWeb, :live_view
  alias ChatBots.Chats
  alias ChatBots.Chats.Bubble
  alias ChatBots.Chats.Image
  alias ChatBots.OpenAi.Api, as: ChatApi
  alias ChatBots.StabilityAi.Api, as: ImageApi
  alias ChatBots.Parser

  def mount(%{"id" => chat_id}, _session, socket) do
    chat = Chats.get_chat!(chat_id)

    socket =
      socket
      |> assign(:chat, chat)
      |> assign(:messages, chat.messages)
      |> assign(:loading, false)

    {:ok, socket}
  end

  def handle_event("submit_message", %{"message" => message_text}, socket) do
    # send a message to self to trigger the API call in the background
    send(self(), :request_chat)

    # add user message to messages
    {:ok, message} =
      Chats.create_message(socket.assigns.chat, %{role: "user", content: message_text})

    messages = socket.assigns.messages ++ [message]

    socket = assign(socket, messages: messages, loading: true)
    {:noreply, socket}
  end

  def handle_info(:request_chat, socket) do
    %{chat: chat, messages: messages} = socket.assigns
    filtered_messages = prepare_messages(messages)

    case ChatApi.send_message(filtered_messages) do
      {:ok, message_attrs} ->
        {:ok, message} = Chats.create_message(chat, message_attrs)
        messages = socket.assigns.messages ++ [message]

        {:noreply,
         socket
         |> assign(messages: messages, loading: false)
         |> maybe_send_image_request()}

      {:error, error} ->
        {:noreply,
         socket
         |> add_message(%{role: "error", content: error["message"]})
         |> assign(socket, loading: false)}
    end
  end

  def handle_info({:request_image, image_prompt}, socket) do
    {:ok, file} = ImageApi.generate_image(image_prompt)
    image_attrs = %{file: file, prompt: image_prompt}
    message_attrs = %{role: "image", content: Jason.encode!(image_attrs)}

    {:noreply,
     add_message(socket, message_attrs)
     |> assign(socket, loading: false)}
  end

  defp convert_messages_to_chat_items(messages) do
    messages
    |> Enum.filter(&(&1.role != "system"))
    |> Enum.flat_map(&Parser.parse(&1))
  end

  defp prepare_messages(messages) do
    messages
    |> Enum.filter(&(&1.role in ["system", "user", "assistant"]))
    |> Enum.map(&Map.take(&1, [:role, :content]))
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

  defp add_message(socket, message_attrs) do
    {:ok, message} = Chats.create_message(socket.assigns.chat, message_attrs)
    messages = socket.assigns.messages ++ [message]

    assign(socket, messages: messages)
  end

  def render(assigns) do
    ~H"""
    <h1 class="mt-0 mb-2 text-5xl font-medium leading-tight text-primary">
      Bot Box
    </h1>
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
end
