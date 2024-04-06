defmodule ChatBots.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :role, :string
      add :content, :string

      timestamps()
    end
  end
end
