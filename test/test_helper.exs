ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(ChatBots.Repo, :manual)

Mox.defmock(ChatBots.OpenAi.MockClient, for: ChatBots.OpenAi.Client)
Application.put_env(:chat_bots, :open_ai_client, ChatBots.OpenAi.MockClient)
