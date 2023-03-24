defmodule ChatBots.Fixtures do
  def api_success_fixture do
    {:ok,
     %{
       choices: [
         %{
           "finish_reason" => "stop",
           "index" => 0,
           "message" => %{
             "content" => "42",
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

  def api_error_fixture do
    {:error,
     %{
       "code" => nil,
       "message" => "Invalid request",
       "param" => nil,
       "type" => "invalid_request_error"
     }}
  end

  def api_unauthorized_fixture do
    {:error,
     %{
       "code" => nil,
       "message" =>
         "You didn't provide an API key. You need to provide your API key in an Authorization header using Bearer auth (i.e. Authorization: Bearer YOUR_KEY), or as the password field (with blank username) if you're accessing the API from your browser and are prompted for a username and password. You can obtain an API key from https://platform.openai.com/account/api-keys.",
       "param" => nil,
       "type" => "invalid_request_error"
     }}
  end
end
