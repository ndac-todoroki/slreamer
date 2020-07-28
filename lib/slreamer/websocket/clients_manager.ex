defmodule Slreamer.Websocket.ClientsManager do
  use GenServer

  require Logger

  ## Client API

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def add(pid), do: GenServer.cast(__MODULE__, {:add, pid})

  def remove(pid), do: GenServer.cast(__MODULE__, {:remove, pid})

  def send(message), do: GenServer.cast(__MODULE__, {:send, message})

  def stop_all(), do: GenServer.cast(__MODULE__, :stop_all)

  ## ServerAPI

  defstruct pids: MapSet.new()

  @impl true
  def init(_) do
    Logger.info("ClientsManager init")
    {:ok, %__MODULE__{}}
  end

  @impl true
  def handle_cast({:add, pid}, %__MODULE__{pids: pids} = state) do
    Logger.debug("CM add client: #{inspect pid}")
    pids = pids |> MapSet.put(pid)

    {:noreply, %{state | pids: pids}}
  end

  def handle_cast({:remove, pid}, %__MODULE__{pids: pids} = state) do
    pids = pids |> MapSet.delete(pid)

    {:noreply, %{state | pids: pids}}
  end

  def handle_cast({:send, message}, %__MODULE__{} = state) do
    Logger.debug("CM sending: #{message}")
    state.pids |> Enum.each(&send(&1, message))

    {:noreply, state}
  end

  def handle_cast(:stop_all, state) do
    state.pids |> Enum.each(&send(&1, :stop))

    {:noreply, %__MODULE__{}}
  end
end
