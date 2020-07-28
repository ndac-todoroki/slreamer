defmodule Slreamer.Slack.CommentDispatcher do
  alias Slreamer.Websocket.ClientsManager

  use GenServer

  require Logger

  ## Client API

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def listen(thread_id), do: GenServer.cast(__MODULE__, {:listen, thread_id})

  def kick(), do: GenServer.cast(__MODULE__, :kick)

  def current_thread_id(), do: GenServer.call(__MODULE__, :current_thread_id)

  def dispatch(thread_id, comment),
    do: GenServer.cast(__MODULE__, {:dispatch, thread_id, comment})

  ## ServerAPI

  defstruct active: false, target_thread: nil, clients: nil

  @impl GenServer
  def init(_) do
    Logger.info("CommentDispatcher init")
    {:ok, %__MODULE__{clients: ClientsManager}}
  end

  @impl GenServer
  def handle_cast({:listen, thread_id}, %__MODULE__{} = state) do
    {:noreply, %{state | target_thread: thread_id, active: true}}
  end

  @impl GenServer
  def handle_cast(:kick, %__MODULE__{} = state) do
    {:noreply, %{state | target_thread: nil, active: false}}
  end

  @impl GenServer
  def handle_cast({:dispatch, _, _}, %__MODULE__{active: false} = state), do: {:noreply, state}

  @impl GenServer
  def handle_cast({:dispatch, thread_id, _}, %__MODULE__{target_thread: target_id} = state)
      when thread_id != target_id,
      do: {:noreply, state}

  @impl GenServer
  def handle_cast({:dispatch, _, comment}, state) when comment |> is_binary do
    Logger.debug("CD dispatch: #{comment}")
    ClientsManager.send(comment)

    {:noreply, state}
  end

  @impl GenServer
  def handle_call(:current_thread_id, _from, %{target_thraed: id} = state) do
    {:reply, id, state}
  end
end
