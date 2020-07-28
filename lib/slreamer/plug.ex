defmodule Slreamer.Plug do
  use Plug.Router

  plug :match
  plug :dispatch

  forward "/webhooks", to: Slreamer.Slack.WebhooksController

  match _ do
    send_resp(conn, 404, "oops")
  end
end
