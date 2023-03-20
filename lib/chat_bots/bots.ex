defmodule ChatBots.Bots do
  alias ChatBots.Bots.Bot

  @doc """
  Returns the list of bots.
  """
  def list_bots do
    [
      %Bot{id: "test_bot", name: "Test Bot", directive: "You are a helpful assistant."}
    ]
  end

  @doc """
  get_box/1 returns the bot with the given id.
  """
  def get_bot(id) do
    list_bots()
    |> Enum.find(&(&1.id == id))
  end
end
