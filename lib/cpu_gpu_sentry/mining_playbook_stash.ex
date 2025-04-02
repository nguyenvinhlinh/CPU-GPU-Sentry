defmodule CpuGpuSentry.MiningPlaybookStash do
  use GenServer
  require Logger

  defmodule MiningPlaybook do
    defstruct [:id, :software_name, :software_version, :module, :command_argument,
               :algorithm_1, :algorithm_2, :coin_name_1, :coin_name_2,
               :expected_status, :current_status, :inserted_at, :updated_at,
               :port]
  end


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
