defmodule ChatBots.BotsTest do
  use ExUnit.Case
  alias ChatBots.Bots
  alias ChatBots.Bots.Bot

  test "list_bots/0 returns a list of Bots" do
    assert [%Bot{} | _] = Bots.list_bots()
  end

  test "get_bot/1 returns a Bot with expected attributes" do
    assert %Bot{} = bot = Bots.get_bot("echo")

    assert bot.id == "echo"
    assert bot.name == "Echo"
    assert bot.directive == "echo"
  end
end
