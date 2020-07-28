defmodule Slreamer.Websocket.Handler do
  @moduledoc """
  WebsocketsのCowboyハンドラ
  """

  @behaviour :cowboy_websocket

  alias Slreamer.Websocket.ClientsManager

  def init(req, state), do: {:cowboy_websocket, req, state}

  def websocket_init(state) do
    ClientsManager.add(self())
    Process.send_after(self(), :ping, 10_000)
    {:reply, {:text, "start"}, state}
    # {:ok, state}
  end

  def websocket_handle(:ping, state) do
    # pingメッセージにpongメッセージを返す
    # IO.puts(:ping)
    {:reply, :pong, state}
  end

  def websocket_handle({:ping, frame}, state) do
    # IO.inspect(:ping, frame)
    {:reply, {:pong, frame}, state}
  end

  def websocket_handle(:pong, state) do
    # IO.puts(:pong)
    # pongメッセージを受け流す
    {:ok, state}
  end

  def websocket_handle({:pong, frame}, state) do
    # IO.inspect(:pong, frame)
    {:ok, state}
  end

  def websocket_info(:ping, state) do
    # IO.puts("sending PING to client")
    Process.send_after(self(), :ping, 10_000)
    {:reply, :ping, state}
  end

  def websocket_info(:stop, state) do
    {:stop, state}
  end

  def websocket_info(message, state) do
    with {:ok, msg} <- Msgpax.pack(%{comment: message}) do
      {:reply, {:binary, msg}, state}
    else
      _ ->
        {:ok, state}
    end
    # {:reply, {:text, message}, state}
  end

  def terminate(_, _, _) do
    ClientsManager.remove(self())
    :ok
  end
end
