defmodule ChatBots.BotsTest do
  use ExUnit.Case
  alias ChatBots.Bots
  alias ChatBots.Bots.Bot

  test "list_bots/0 returns a list of Bots" do
    assert [%Bot{} | _] = Bots.list_bots()
  end

  test "get_bot/1 returns a Bot with expected attributes" do
    assert %Bot{} = bot = Bots.get_bot("test_bot")

    assert bot.id == "test_bot"
    assert bot.name == "Test Bot"
    assert bot.directive == "You are a helpful assistant."
  end
end
