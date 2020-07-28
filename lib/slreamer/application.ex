defmodule Slreamer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    dispatch = [
      {:_,
       [
         {"/ws", Slreamer.Websocket.Handler, []},
         {:_, Plug.Cowboy.Handler, {Slreamer.Plug, []}}
       ]}
    ]

    children = [
      # Starts a worker by calling: Slreamer.Worker.start_link(arg)
      # {Slreamer.Worker, arg}
      Slreamer.Websocket.ClientsManager,
      Slreamer.Slack.CommentDispatcher,
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: WebApi.Plug,
        options: [port: 4000, dispatch: dispatch]
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Slreamer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
