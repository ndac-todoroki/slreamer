defmodule Slreamer.Slack.WebhooksController do
  use Plug.Router

  require Logger

  alias Slreamer.Slack.CommentDispatcher
  alias Slreamer.Slack.Writer

  @invite_command "コメント太郎召喚"
  @kick_command "コメント太郎粉砕"

  plug :match
  plug Plug.Parsers, parsers: [:json], json_decoder: Jason
  plug :dispatch
  plug Plug.Logger

  post "/" do
    react(conn, conn.body_params)
  end

  def react(conn, %{"type" => "event_callback", "event" => event} = _body) do
    Task.start(fn -> do_dispatch(event) end)

    send_resp(conn, 200, "")
  end

  def react(conn, %{"type" => "url_verification", "challenge" => challenge}) do
    body = %{challenge: challenge} |> Jason.encode!()

    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(200, body)
  end

  def react(conn, _body) do
    # body |> IO.inspect()
    # conn.body_params |> IO.inspect
    conn |> Plug.Conn.send_resp(200, "")
  end

  @spec do_dispatch(any) :: :ok
  defp do_dispatch(%{"edited" => _}), do: :ok
  defp do_dispatch(%{"hidden" => _}), do: :ok

  defp do_dispatch(%{
         "type" => "message",
         "channel" => channel,
         "thread_ts" => thread,
         "text" => @invite_command
       }),
       do: invite_bot(channel, thread)

  defp do_dispatch(%{
         "type" => "message",
         "text" => @kick_command,
         "channel" => channel,
         "thread_ts" => thread
       }),
       do: kick_bot(channel, thread)

  defp do_dispatch(%{
         "type" => "message",
         "channel" => channel,
         "text" => @invite_command
       }),
       do: miss!(channel)

  defp do_dispatch(%{"type" => "message", "thread_ts" => thread, "text" => text}),
    do: CommentDispatcher.dispatch(thread, text)

  defp do_dispatch(_), do: :ok

  def invite_bot(channel, thread) do
    CommentDispatcher.listen(thread)

    Writer.joined()
    |> Writer.set_reply(channel, thread)
    |> Jason.encode!()
    |> Writer.post()
  end

  def kick_bot(channel, thread) do
    CommentDispatcher.kick()

    Writer.kicked()
    |> Writer.set_reply(channel, thread)
    |> Jason.encode!()
    |> Writer.post()
  end

  def miss!(channel) do
    Writer.miss!()
    |> Writer.set_channel(channel)
    |> Jason.encode!()
    |> Writer.post()
  end
end
