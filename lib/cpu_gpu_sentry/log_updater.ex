defmodule CpuGpuSentry.LogUpdater do
  use GenServer
  require Logger

  def start_link(_args), do: CpuGpuSentry.LogUpdater.start_link()
  def start_link() do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    Logger.info("[CpuGpuSentry.LogUpdater] Started")
    {:ok, pid}
  end

  @impl true
  def init(_args) do
    Process.send_after(__MODULE__, :execute_loop, 30_000)
    {:ok, nil}
  end

    @impl true
  def handle_info(:execute_loop, _state) do
    execute()
    Process.send_after(__MODULE__, :execute_loop, 5_000)
    {:noreply, nil}
  end

  def execute() do
    Logger.info("[CpuGpuSentry.LogUpdater] execute")
    playbook_list = CpuGpuSentry.MiningPlaybookStash.get_all()
    for {_playbook_id, playbook}  <- playbook_list do
      if playbook.current_status == :mining do
        hashrate_summary = Kernel.apply(playbook.module, :get_hashrate_summary, [])
        CpuGpuSentry.CpuGpuMinerLogStash.update_hashrate_summary(hashrate_summary)
      end
    end
  end
end
