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
    lan_ip = get_lan_ip()
    wan_ip = get_wan_ip()
    uptime = get_uptime()
    CpuGpuSentry.LogStash.update(:lan_ip, lan_ip)
    CpuGpuSentry.LogStash.update(:wan_ip, wan_ip)
    CpuGpuSentry.LogStash.update(:uptime, uptime)
  end

  def execute_loop() do
    Logger.info("[CpuGpuSentry.LogUpdater] execute")

    cpu_temp = get_cpu_temp()
    CpuGpuSentry.LogStash.update(:cpu_temp, cpu_temp)
    gpu_data_map = get_gpu_data()
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

  def get_lan_ip() do
    arg_list = ["-o", "route", "get", "to", "8.8.8.8"]
    {ip_cmd_output, _status} = System.cmd("ip", arg_list)
    parse_lan_ip(ip_cmd_output)
  end

  def parse_lan_ip(ip_output) do
    regular_expression = ~r/src (?<lan_ip>[0-9.]+)/
    Regex.named_captures(regular_expression, ip_output)
    |> Map.get("lan_ip")
  end

  def get_wan_ip() do
    url = "https://api.ipify.org"
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> body
      _ ->
        Logger.error("[CpuGpuSentry.LogUpdater] Cannot get WAN IP")
        nil
    end
  end

  def get_uptime() do
    command = "uptime"
    if is_command_exist?(command) do
      {uptime_cmd_output, _status} = System.cmd("uptime", ["-p"])

      uptime_cmd_output
      |> String.replace("up ", "")
      |> String.replace("\n", "")
    else
      Logger.warn("[CpuGpuSentry.LogUpdater] get_uptime/0 does not work due to #{command} not found.")
      nil
    end
  end

  def get_cpu_temp() do
    command = "sensors"
    if is_command_exist?(command) do
      {sensors_cmd_output, _status } = System.cmd("sensors", ["-j"])
      parse_cpu_temp(sensors_cmd_output)
    else
      Logger.warn("[CpuGpuSentry.LogUpdater] get_cpu_temp/0 does not work due to #{command} not found.")
      nil
    end
  end

  def get_gpu_data() do
    command = "nvidia-smi"
    if is_command_exist?(command) do
      {nvidia_smi_cmd_output, _status } = System.cmd(command,
        ["--query-gpu=pci.bus_id,name,temperature.gpu,temperature.memory,clocks.current.graphics,clocks.current.memory,fan.speed,power.draw",
         "--format=csv"])
      parse_gpu_data(nvidia_smi_cmd_output)
    else
      Logger.warn("[CpuGpuSentry.LogUpdater] get_gpu_data/0 does not work due to #{command} not found.")
      %{}
    end
  end

  def parse_cpu_temp(sensors_cmd_output) when Kernel.is_binary(sensors_cmd_output) do
    sensors_cmd_output_map = Jason.decode!(sensors_cmd_output)

    temp_1 = parse_cpu_temp_type_1(sensors_cmd_output_map)
    temp_2 = parse_cpu_temp_type_2(sensors_cmd_output_map)

    [temp_1, temp_2]
    |> Enum.filter( &(&1 != nil))
    |> Enum.max()
  end

  def parse_cpu_temp_type_1(sensors_cmd_output_map) when Kernel.is_map(sensors_cmd_output_map) do
    cpu_temp_1 = Map.get(sensors_cmd_output_map, "coretemp-isa-0000", %{})
    |> Map.get("Package id 0", %{})
    |> Map.get("temp1_input", -1)

    cpu_temp_2 = Map.get(sensors_cmd_output_map, "coretemp-isa-0001", %{})
    |> Map.get("Package id 1", %{})
    |> Map.get("temp1_input", -1)

    temp = Enum.max([cpu_temp_1, cpu_temp_2])

    if temp == -1, do: nil, else: Kernel.ceil(temp)
  end

  def parse_cpu_temp_type_2(sensors_cmd_output_map) when Kernel.is_map(sensors_cmd_output_map) do
    temp= Map.get(sensors_cmd_output_map, "k10temp-pci-00c3", %{})
    |> Map.get("Tctl", %{})
    |> Map.get("temp1_input")

    if temp == nil,  do: nil, else: Kernel.ceil(temp)
  end



  def parse_gpu_data(nvidia_smi_output) do
    nvidia_smi_output
    |> String.split("\n")
    |> Enum.drop(1)
    |> Enum.drop(-1)
    |> Enum.sort()
    |> Enum.with_index(1)
    |> Enum.reduce(%{gpu_fan_uom: "%"}, fn({csv_line, index}, acc) ->
      [_bus_id, _gpu_name, core_temp, _mem_temp, core_clock, mem_clock, fan, power] = String.split(csv_line, ",")

      core_temp_key = "gpu_#{index}_core_temp" |> String.to_atom()
      core_temp_value = String.trim(core_temp) |> String.to_integer()

      mem_temp_key = "gpu_#{index}_mem_temp" |> String.to_atom()
      mem_temp_value = nil

      core_clock_key = "gpu_#{index}_core_clock" |> String.to_atom()
      core_clock_value = core_clock
      |> String.replace("MHz", "")
      |> String.trim()
      |> String.to_integer()

      mem_clock_key = "gpu_#{index}_mem_clock" |> String.to_atom()
      mem_clock_value = mem_clock
      |> String.replace("MHz", "")
      |> String.trim()
      |> String.to_integer()

      fan_key = "gpu_#{index}_fan" |> String.to_atom()
      fan_value = fan
      |> String.replace("%", "")
      |> String.trim()
      |> String.to_integer()

      power_key = "gpu_#{index}_power" |> String.to_atom()
      power_value = power
      |> String.replace("W", "")
      |> String.trim()
      |> String.to_float()
      |> Kernel.ceil()

      acc
      |> Map.put(core_temp_key,  core_temp_value)
      |> Map.put(core_clock_key, core_clock_value)
      |> Map.put(mem_clock_key,  mem_clock_value)
      |> Map.put(mem_temp_key,   mem_temp_value)
      |> Map.put(fan_key,        fan_value)
      |> Map.put(power_key,      power_value)
    end)
  end

  def is_command_exist?(command) when Kernel.is_binary(command) do
    case System.cmd("which", [command]) do
      {_, 0} -> true
      {_, 1} -> false
    end
  end
end
