defmodule CpuGpuSentry.SystemData do
  require Logger

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
