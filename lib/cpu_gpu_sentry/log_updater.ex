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

    playbook_list = CpuGpuSentry.MiningPlaybookStash.get_all()
    for {_playbook_id, playbook}  <- playbook_list do
      if playbook.current_status == :mining do
        hashrate_summary = Kernel.apply(playbook.module, :get_hashrate_summary, [])
        CpuGpuSentry.LogStash.update_hashrate_summary(hashrate_summary)

        CpuGpuSentry.LogStash.update(:cpu_coin_name, playbook.cpu_coin_name)
        CpuGpuSentry.LogStash.update(:gpu_coin_name_1, playbook.gpu_coin_name_1)
        CpuGpuSentry.LogStash.update(:gpu_coin_name_2, playbook.gpu_coin_name_2)

        CpuGpuSentry.LogStash.update(:cpu_algorithm, playbook.cpu_algorithm)
        CpuGpuSentry.LogStash.update(:gpu_algorithm_1, playbook.gpu_algorithm_1)
        CpuGpuSentry.LogStash.update(:gpu_algorithm_2, playbook.gpu_algorithm_2)

        CpuGpuSentry.LogStash.update(:cpu_pool_address, playbook.cpu_pool_address)
        CpuGpuSentry.LogStash.update(:gpu_pool_address_1, playbook.gpu_pool_address_1)
        CpuGpuSentry.LogStash.update(:gpu_pool_address_2, playbook.gpu_pool_address_2)

        CpuGpuSentry.LogStash.update(:cpu_wallet_address, playbook.cpu_wallet_address)
        CpuGpuSentry.LogStash.update(:gpu_wallet_address_1, playbook.gpu_wallet_address_1)
        CpuGpuSentry.LogStash.update(:gpu_wallet_address_2, playbook.gpu_wallet_address_2)
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
    {uptime_cmd_output, _status} = System.cmd("uptime", ["-p"])

    uptime_cmd_output
    |> String.replace("up ", "")
    |> String.replace("\n", "")
  end

  def get_cpu_temp() do
    {sensors_cmd_output, _status } = System.cmd("sensors", ["-j"])
    parse_cpu_temp(sensors_cmd_output)
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
end
