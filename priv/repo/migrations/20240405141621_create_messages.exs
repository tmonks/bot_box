defmodule ChatBots.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :chat_id, references(:chats, on_delete: :delete_all)
      add :role, :string
      add :content, :string

      timestamps()
    end
  end
end
