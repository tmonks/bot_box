defmodule ChatBots.Chats do
  alias ChatBots.Bots
  alias ChatBots.Chats.Chat
  alias ChatBots.Chats.Message
  alias ChatBots.Repo

  import Ecto.Changeset
  import Ecto.Query

  @doc """
  Creates a new chat for the given bot_id.
  Adds a message with the bot's system prompt.
  """
  def create_chat(bot) do
    %Chat{}
    |> change(bot_id: bot.id)
    |> put_assoc(:messages, [%Message{role: "system", content: bot.directive}])
    |> Repo.insert!()
  end

  @doc """
  Retrieves a chat by id
  """
  def get_chat!(id) do
    Repo.get!(Chat, id)
    |> Repo.preload([:messages, :bot])
  end

  @doc """
  Creates a new message for the given chat
  """
  def create_message(chat, attrs) do
    %Message{}
    |> cast(attrs, [:role, :content])
    |> put_assoc(:chat, chat)
    |> Repo.insert()
  end

  @doc """
  Creates a new chat with the given bot_id.
  """
  def new_chat(bot_id) do
    bot = Bots.get_bot(bot_id)
    system_prompt = %Message{role: "system", content: bot.directive}
    [system_prompt]
  end

  @doc """
  Adds a message to the chat.
  """
  def add_message(messages, message) do
    messages ++ [message]
  end

  @doc """
  Lists all chats
  Preloads messages
  """
  def list_chats do
    preload_query = preload_latest_message_query()

    from(c in Chat,
      order_by: [desc: :inserted_at],
      preload: [:bot, :messages, latest_message: ^preload_query]
    )
    |> Repo.all()
  end

  defp preload_latest_message_query do
    ranking_query =
      from(m in Message,
        select: %{id: m.id, row_number: over(row_number(), :message_partition)},
        windows: [message_partition: [partition_by: :chat_id, order_by: [desc: m.inserted_at]]]
      )

    from(m in Message,
      join: r in subquery(ranking_query),
      on: m.id == r.id and r.row_number == 1
    )
  end
end
