defmodule ChatBots.Chats.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [])
    |> validate_required([])
  end
end
