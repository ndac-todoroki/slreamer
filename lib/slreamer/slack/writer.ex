defmodule Slreamer.Slack.Writer do
  @token_key "SLREAMER_SLACK_TOKEN"
  @chat_post_message "https://slack.com/api/chat.postMessage"

  def post(body), do: HTTPoison.post(@chat_post_message, body, headers())

  def set_reply(map, channel, thread) do
    map
    |> set_channel(channel)
    |> Map.put(:thread_ts, thread)
  end

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

  def miss! do
    %{
      response_type: :in_channel,
      blocks: [
        %{
          type: :section,
          text: %{
            type: :mrkdwn,
            text: ":bow: 召喚はスレッドでしかできません :bow:"
          }
        }
      ]
    }
  end

  def joined do
    %{
      response_type: :in_channel,
      blocks: [
        %{
          type: :section,
          text: %{
            type: :mrkdwn,
            text: ":eyes:"
          }
        }
      ]
    }
  end

  def disabled do
    %{
      response_type: :in_channel,
      blocks: [
        %{
          type: :section,
          text: %{
            type: :mrkdwn,
            text: ":money_with_wings:"
          }
        }
      ]
    }
  end

  def kicked do
    %{
      response_type: :in_channel,
      blocks: [
        %{
          type: :section,
          text: %{
            type: :mrkdwn,
            text: ":dead_mario:"
          }
        }
      ]
    }
  end
end
