defmodule ChatBots.Bots do
  alias ChatBots.Bots.Bot

  @doc """
  Returns the list of bots.
  """
  def list_bots do
    [
      %Bot{id: "echo", name: "Echo", directive: "echo"},
      %Bot{id: "reverse", name: "Reverse", directive: "reverse"},
      %Bot{id: "uppercase", name: "Uppercase", directive: "uppercase"}
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
