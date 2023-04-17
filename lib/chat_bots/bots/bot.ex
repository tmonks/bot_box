defmodule ChatBots.Bots.Bot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bots" do
    field(:directive, :string)
    field(:name, :string)

    timestamps()
  end

  @doc false
  def changeset(bot, attrs) do
    bot
    |> cast(attrs, [:name, :directive])
    |> validate_required([:name, :directive])
  end
end
