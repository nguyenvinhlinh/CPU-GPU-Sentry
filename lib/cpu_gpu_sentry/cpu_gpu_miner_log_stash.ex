defmodule CpuGpuSentry.LogStash do
  use GenServer
  require Logger
  defmodule State do
    defstruct [:cpu_temp, :cpu_hashrate, :cpu_hashrate_uom, :cpu_algorithm, :cpu_coin_name,
               :cpu_pool_address, :cpu_wallet_address, :cpu_power,
               :gpu_1_core_temp, :gpu_2_core_temp, :gpu_3_core_temp, :gpu_4_core_temp,
               :gpu_5_core_temp, :gpu_6_core_temp, :gpu_7_core_temp, :gpu_8_core_temp,

               :gpu_1_mem_temp, :gpu_2_mem_temp, :gpu_3_mem_temp, :gpu_4_mem_temp,
               :gpu_5_mem_temp, :gpu_6_mem_temp, :gpu_7_mem_temp, :gpu_8_mem_temp,

               :gpu_1_hashrate_1, :gpu_2_hashrate_1, :gpu_3_hashrate_1, :gpu_4_hashrate_1,
               :gpu_5_hashrate_1, :gpu_6_hashrate_1, :gpu_7_hashrate_1, :gpu_8_hashrate_1,

               :gpu_1_hashrate_2, :gpu_2_hashrate_2, :gpu_3_hashrate_2, :gpu_4_hashrate_2,
               :gpu_5_hashrate_2, :gpu_6_hashrate_2, :gpu_7_hashrate_2, :gpu_8_hashrate_2,

               :gpu_1_core_clock, :gpu_2_core_clock, :gpu_3_core_clock, :gpu_4_core_clock,
               :gpu_5_core_clock, :gpu_6_core_clock, :gpu_7_core_clock, :gpu_8_core_clock,

               :gpu_1_mem_clock, :gpu_2_mem_clock, :gpu_3_mem_clock, :gpu_4_mem_clock,
               :gpu_5_mem_clock, :gpu_6_mem_clock, :gpu_7_mem_clock, :gpu_8_mem_clock,

               :gpu_1_power, :gpu_2_power, :gpu_3_power, :gpu_4_power,
               :gpu_5_power, :gpu_6_power, :gpu_7_power, :gpu_8_power,

               :gpu_1_fan, :gpu_2_fan, :gpu_3_fan, :gpu_4_fan,
               :gpu_5_fan, :gpu_6_fan, :gpu_7_fan, :gpu_8_fan,

               :gpu_fan_uom,

               :gpu_algorithm_1, :gpu_algorithm_2,
               :gpu_hashrate_uom_1, :gpu_hashrate_uom_2,
               :gpu_coin_name_1, :gpu_coin_name_2,

               :gpu_pool_address_1, :gpu_pool_address_2,
               :gpu_wallet_address_1, :gpu_wallet_address_2,
               :lan_ip, :wan_ip, :uptime]
  end

  def start_link(_args), do: start_link()
  def start_link() do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    Logger.info("[CpuGpuSentry.LogStash] Started")
    {:ok, pid}
  end

  def update_hashrate_summary(%MinerProvision.HashrateSummary{}=hashrate_summary) do
    GenServer.cast(__MODULE__, {:update_hashrate_summary, hashrate_summary})
  end

  def update(key, value) when Kernel.is_atom(key) do
    GenServer.cast(__MODULE__, {:update, key, value})
  end

  def update_with_map(a_map) when Kernel.is_map(a_map) do
    GenServer.cast(__MODULE__, {:update_with_map, a_map})
  end

  def get() do
    GenServer.call(__MODULE__, :get)
  end


  @impl true
  def init(_params) do
    {:ok, %CpuGpuSentry.LogStash.State{}}
  end

  @impl true
  def handle_cast({:update_hashrate_summary, %MinerProvision.HashrateSummary{}=hashrate_summary}, state) do
    hashrate_summary_map = Map.from_struct(hashrate_summary)
    state_mod =
      Enum.reduce(hashrate_summary_map, state, fn({e_key, e_value}, acc) ->
        Map.put(acc, e_key, e_value)
      end)
    {:noreply, state_mod}
  end

  @impl true
  def handle_cast({:update, key, value}, state) do
    state_mod = Map.put(state, key, value)
    {:noreply, state_mod}
  end

  @impl true
  def handle_cast({:update_with_map, a_map}, state) when Kernel.is_map(a_map) do
    state_mod =
      Enum.reduce(a_map, state, fn({key, value} , acc) ->
        Map.put(acc, key, value)
      end)
    {:noreply, state_mod}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end
end
