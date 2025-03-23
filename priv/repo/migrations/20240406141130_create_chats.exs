defmodule ChatBots.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :bot_id, references(:bots, on_delete: :restrict)

      timestamps()
    end
  end
end
