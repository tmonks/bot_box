defmodule Mix.Tasks.Seed do
  @moduledoc """
  Mix task to run the seeder
  """
  use Mix.Task

  alias ChatBots.Seeder

  @shortdoc "Runs the Seeder to update the bots"
  def run(_) do
    # Ensure the application is started
    Mix.Task.run("app.start")
    Seeder.update_bots()
  end
end
