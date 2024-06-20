defmodule ChatBots.Repo.Migrations.AddJsonModeToBots do
  use Ecto.Migration

  def change do
    # add json_mode boolean column to bots table
    alter table(:bots) do
      add :json_mode, :boolean, default: false
    end
  end
end
