defmodule Slreamer.Slack.Leaver do
  @token_key "SLREAMER_SLACK_TOKEN"
  @conversation_leave "https://slack.com/api/conversations.leave"

  def act(body), do: HTTPoison.post(@conversation_leave, body, headers())

  def set_channel(map, channel) do
    map
    |> Map.put(:channel, channel)
  end

  defp token, do: System.get_env(@token_key, "")

  defp headers,
    do: [
      {"Authorization", "Bearer " <> token()},
      {"Content-Type", "application/json"}
    ]
end
