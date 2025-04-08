defmodule CpuGpuSentry.MiningPlaybookStash do
  use GenServer
  require Logger
  alias CpuGpuSentry.MiningPlaybookStash.MiningPlaybook

  def start_link(_args), do: start_link()
  def start_link() do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    pid_string = pid
    |> :erlang.pid_to_list()
    |> to_string()
    Logger.info("[CpuGpuSentry.MiningPlaybookStash] PID:#{pid_string} Started ")
    {:ok, pid}
  end

  def clear() do
    GenServer.cast(__MODULE__, :clear)
  end

  def insert(%MiningPlaybook{}=mining_playbook) do
    GenServer.cast(__MODULE__, {:insert, mining_playbook})
  end

  def get_all() do
    GenServer.call(__MODULE__, :get_all)
  end

  def get(playbook_id) do
    GenServer.call(__MODULE__, {:get, playbook_id})
  end

  @impl true
  def init(_args) do
    state = %{}
    {:ok, state}
  end


  @impl true
  def handle_cast(:clear, _state) do
    new_state = %{}
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:insert, mining_playbook}, state) do
    new_state = state
    |> Map.put(mining_playbook.id, mining_playbook)
    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get_all, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:get, id}, _from, state) do
    mining_playbook = Map.get(state, id)
    {:reply, mining_playbook, state}
  end
end
