defmodule ChatBots.Bots do
  alias ChatBots.Repo
  alias ChatBots.Bots.Bot
  import Ecto.Query

  @doc """
  Returns the list of bots.
  """
  def list_bots do
    Bot |> Repo.all()
  end

  @doc """
  get_box/1 returns the bot with the given id.
  """
  def get_bot(id) do
    Bot
    |> where([b], b.id == ^id)
    |> Repo.one()
  end

  @doc """
  create_bot/1 creates a new bot with the given attributes.
  """
  def create_bot(attrs) do
    %Bot{}
    |> Bot.changeset(attrs)
    |> Repo.insert(on_conflict: :replace_all, conflict_target: :name)
  end
end
