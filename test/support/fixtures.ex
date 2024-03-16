defmodule ChatBots.Fixtures do
  alias ChatBots.Repo
  alias ChatBots.Bots.Bot

  def api_success_fixture(response_map) when is_map(response_map) do
    json = Jason.encode!(response_map)
    api_success_fixture(json)
  end

  def api_success_fixture(response_text) do
    {:ok,
     %{
       choices: [
         %{
           "finish_reason" => "stop",
           "index" => 0,
           "message" => %{
             "content" => response_text,
             "role" => "assistant"
           }
         }
       ],
       created: 1_679_238_705,
       id: "chatcmpl-6vozBYg28ott0ZfyQFPTH3kEQnbQ1",
       model: "gpt-3.5-turbo-0301",
       object: "chat.completion",
       usage: %{"completion_tokens" => 38, "prompt_tokens" => 27, "total_tokens" => 65}
     }}
  end

  def api_json_response() do
    {:ok,
     %{
       id: "chatcmpl-8xykPfT6zxeijbLiidVydQZ0y7spX",
       usage: %{
         "completion_tokens" => 30,
         "prompt_tokens" => 56,
         "total_tokens" => 86
       },
       model: "gpt-3.5-turbo-0125",
       choices: [
         %{
           "finish_reason" => "stop",
           "index" => 0,
           "logprobs" => nil,
           "message" => %{
             "content" =>
               "{\n  \"response\": \"The average distance between the Earth and the Sun is approximately 93 million miles, or about 150 million kilometers.\"\n}",
             "role" => "assistant"
           }
         }
       ],
       object: "chat.completion",
       created: 1_709_305_557,
       system_fingerprint: "fp_2b778c6b35"
     }}
  end

  def api_text_response do
    {:ok,
     %{
       id: "chatcmpl-8yJ8HRzy3tOhCcIS3XiPG3J8j8RSF",
       usage: %{
         "completion_tokens" => 19,
         "prompt_tokens" => 173,
         "total_tokens" => 192
       },
       model: "gpt-3.5-turbo-0125",
       choices: [
         %{
           "finish_reason" => "stop",
           "index" => 0,
           "logprobs" => nil,
           "message" => %{
             "content" => "Oh, just a casual 93 million miles. You know, a quick road trip away.",
             "role" => "assistant"
           }
         }
       ],
       created: 1_709_383_917,
       object: "chat.completion",
       system_fingerprint: "fp_2b778c6b35"
     }}
  end

  def api_error_fixture do
    {:error,
     %{
       "error" => %{
         "code" => nil,
         "message" => "Invalid request",
         "param" => nil,
         "type" => "invalid_request_error"
       }
     }}
  end

  def api_timeout_fixture do
    {:error, :timeout}
  end

  def api_unauthorized_fixture do
    {:error,
     %{
       "error" => %{
         "code" => nil,
         "message" =>
           "You didn't provide an API key. You need to provide your API key in an Authorization header using Bearer auth (i.e. Authorization: Bearer YOUR_KEY), or as the password field (with blank username) if you're accessing the API from your browser and are prompted for a username and password. You can obtain an API key from https://platform.openai.com/account/api-keys.",
         "param" => nil,
         "type" => "invalid_request_error"
       }
     }}
  end

  def bot_fixture(attrs \\ %{}) do
    Bot
    |> struct!(bot_attrs(attrs))
    |> Repo.insert!()
  end

  def bot_attrs(attrs) do
    attrs
    |> Enum.into(%{name: "Test Bot", directive: "You are a helpful assistant."})
  end
end
