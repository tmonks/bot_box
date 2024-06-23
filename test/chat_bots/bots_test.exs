defmodule ChatBots.BotsTest do
  use ChatBots.DataCase
  alias ChatBots.Bots
  alias ChatBots.Repo
  import ChatBots.Fixtures

  test "list_bots/0 returns a list of Bots" do
    bot = bot_fixture(%{name: "Test Bot", directive: "You are a helpful assistant."})

    assert [^bot] = Bots.list_bots()
  end

  test "get_bot/1 returns a Bot with expected attributes" do
    bot = bot_fixture()

    assert ^bot = Bots.get_bot(bot.id)
  end

  test "create_bot/1 creates a new Bot" do
    assert {:ok, bot} =
             Bots.create_bot(%{name: "Test Bot", directive: "You are a helpful assistant."})

    assert bot.name == "Test Bot"
    assert bot.directive == "You are a helpful assistant."
  end

  test "create_bot/1 updates the bot if the name is already taken" do
    bot_fixture(%{name: "Test Bot", directive: "You are a useless assistant."})

    assert {:ok, bot} =
             Bots.create_bot(%{name: "Test Bot", directive: "You are a helpful assistant."})

    assert %{directive: "You are a helpful assistant."} = Repo.reload(bot)
  end
end
