defmodule ChatBots.StabilityAi.ApiTest do
  use ChatBotsWeb.ConnCase, async: true

  import Mox
  alias ChatBots.StabilityAi.Api
  alias ChatBots.StabilityAi.MockClient

  setup [:verify_on_exit!, :setup_environment]

  describe "generate_image/1" do
    test "sends a post request with the expected params to the API" do
      MockClient
      |> expect(:post, fn url, options ->
        assert url ==
                 "https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image"

        assert {"Authorization", "Bearer StaB1l1tyA1"} in options[:headers]
        assert {"Content-Type", "application/json"} in options[:headers]
        assert {"Accept", "application/json"} in options[:headers]

        %{text_prompts: text_prompts} = Keyword.get(options, :json)
        assert %{text: "a cute fluffy cat", weight: 1} in text_prompts

        {:ok,
         %Req.Response{
           body: %{
             "artifacts" => [
               %{
                 "base64" => "Zm9vYmFy",
                 "seed" => 12345
               }
             ]
           }
         }}
      end)

      date = Date.utc_today() |> Date.to_iso8601() |> String.replace("-", "")
      expected_filename = "img-#{date}-12345.png"

      assert {:ok, ^expected_filename} =
               Api.generate_image("a cute fluffy cat", %{style_preset: "awesome"})
    end
  end

  defp setup_environment(_) do
    Application.put_env(:chat_bots, :stability_ai_api_key, "StaB1l1tyA1")
  end
end
