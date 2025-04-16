defmodule CpuGpuSentry.LogUpdater do
  use GenServer
  require Logger
  alias CpuGpuSentry.SystemData

  def start_link(_args), do: CpuGpuSentry.LogUpdater.start_link()
  def start_link() do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    Logger.info("[CpuGpuSentry.LogUpdater] Started")
    {:ok, pid}
  end

  @impl true
  def init(_args) do
    Process.send_after(__MODULE__, :execute_once, 10_000)
    Process.send_after(__MODULE__, :execute_loop, 30_000)
    {:ok, nil}
  end

  @impl true
  def handle_info(:execute_once, _state) do
    execute_once()
    {:noreply, nil}
  end

  @impl true
  def handle_info(:execute_loop, _state) do
    execute_loop()
    Process.send_after(__MODULE__, :execute_loop, 5_000)
    {:noreply, nil}
  end

  def execute_once() do
    lan_ip = SystemData.get_lan_ip()
    wan_ip = SystemData.get_wan_ip()
    uptime = SystemData.get_uptime()
    CpuGpuSentry.LogStash.update(:lan_ip, lan_ip)
    CpuGpuSentry.LogStash.update(:wan_ip, wan_ip)
    CpuGpuSentry.LogStash.update(:uptime, uptime)
  end

  def execute_loop() do
    Logger.info("[CpuGpuSentry.LogUpdater] execute")

    cpu_temp = SystemData.get_cpu_temp()
    CpuGpuSentry.LogStash.update(:cpu_temp, cpu_temp)

    uptime = SystemData.get_uptime()
    CpuGpuSentry.LogStash.update(:uptime, uptime)

    gpu_data_map = SystemData.get_gpu_data()
    CpuGpuSentry.LogStash.update_with_map(gpu_data_map)

    playbook_list = CpuGpuSentry.MiningPlaybookStash.get_all()
    for {_playbook_id, playbook}  <- playbook_list do
      if playbook.current_status == :mining do
        hashrate_summary = Kernel.apply(playbook.module, :get_hashrate_summary, [])
        CpuGpuSentry.LogStash.update_hashrate_summary(hashrate_summary)

        update_map = %{
          cpu_coin_name: playbook.cpu_coin_name,
          gpu_coin_name_1: playbook.gpu_coin_name_1,
          gpu_coin_name_2: playbook.gpu_coin_name_2,

          cpu_algorithm: playbook.cpu_algorithm,
          gpu_algorithm_1: playbook.gpu_algorithm_1,
          gpu_algorithm_2: playbook.gpu_algorithm_2,

          cpu_pool_address: playbook.cpu_pool_address,
          gpu_pool_address_1: playbook.gpu_pool_address_1,
          gpu_pool_address_2: playbook.gpu_pool_address_2,

          cpu_wallet_address: playbook.cpu_wallet_address,
          gpu_wallet_address_1: playbook.gpu_wallet_address_1,
          gpu_wallet_address_2: playbook.gpu_wallet_address_2,
        }
        CpuGpuSentry.LogStash.update_with_map(update_map)
      end
    end
  end
end
