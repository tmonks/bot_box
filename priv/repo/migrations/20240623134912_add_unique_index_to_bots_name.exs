defmodule ChatBots.Repo.Migrations.AddUniqueIndexToBotsName do
  use Ecto.Migration

  def change do
    create unique_index(:bots, [:name])
  end
end
