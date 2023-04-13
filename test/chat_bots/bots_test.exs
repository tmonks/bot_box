defmodule ChatBots.BotsTest do
  use ChatBots.DataCase
  alias ChatBots.Bots
  import ChatBots.Fixtures

  test "list_bots/0 returns a list of Bots" do
    bot = bot_fixture(%{name: "Test Bot", directive: "You are a helpful assistant."})

    assert [^bot] = Bots.list_bots()
  end

  test "get_bot/1 returns a Bot with expected attributes" do
    bot = bot_fixture()

    assert ^bot = Bots.get_bot(bot.id)
  end
end
