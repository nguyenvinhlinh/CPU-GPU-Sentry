defmodule CpuGpuSentry.TemporaryMiningPlaybookStash do
  use GenServer
  require Logger

  def start_link(_args), do: start_link()
  def start_link() do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    pid_string = pid
    |> :erlang.pid_to_list()
    |> to_string()
    Logger.info("[CpuGpuSentry.TemporaryMiningPlaybookStash] PID:#{pid_string} Started ")
    {:ok, pid}
  end

  def clear() do
    GenServer.cast(__MODULE__, :clear)
  end

  def insert(mining_playbook) do
    mining_playbook_mod = %CpuGpuSentry.MiningPlaybookStash.MiningPlaybook{
      id: Map.get(mining_playbook, "id"),
      software_name: Map.get(mining_playbook, "software_name"),
      software_version: Map.get(mining_playbook, "software_version"),
      module: Map.get(mining_playbook, "module") |> String.to_atom(),
      algorithm_1: Map.get(mining_playbook, "algorithm_1"),
      algorithm_2: Map.get(mining_playbook, "algorithm_2"),
      coin_name_1: Map.get(mining_playbook, "coin_name_1"),
      coin_name_2: Map.get(mining_playbook, "coin_name_2"),
      expected_status: Map.get(mining_playbook, "expected_status"),
      inserted_at: Map.get(mining_playbook, "inserted_at") |> NaiveDateTime.from_iso8601!(),
      updated_at: Map.get(mining_playbook, "updated_at") |> NaiveDateTime.from_iso8601!()
    }

    GenServer.cast(__MODULE__, {:insert, mining_playbook_mod})
  end

  def get_all() do
    GenServer.call(__MODULE__, :get_all)
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
end
