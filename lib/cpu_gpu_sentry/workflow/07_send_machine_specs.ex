defmodule CpuGpuSentry.Workflow.SendMachineSpecs do
  require Logger

  def execute() do
    body = init_body_map()
    |> Map.put(:cpu_name, get_cpu_name())
    |> Map.put(:motherboard_name, get_motherboard_name())
    |> Map.put(:ram_size, get_ram_size())
    |> Map.merge(get_gpu_name_map())

    mininig_rig_commander_api_url = Application.get_env(:cpu_gpu_sentry, :mininig_rig_commander_api_url)
    cpu_gpu_spec_url = Path.join([mininig_rig_commander_api_url, "cpu_gpu_miners", "specs"])
    api_code = Application.get_env(:cpu_gpu_sentry, :api_code)
    header_list = [
      {"content-type", "application/json"},
      {"api_code", api_code}
    ]
    option_list =  CpuGpuSentry.HTTPoisonOption.option_list()
    body_encoded = Jason.encode!(body)

    case HTTPoison.post(cpu_gpu_spec_url, body_encoded, header_list, option_list) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Logger.info("[Workflow.SendMachineSpecs] Send machine specs to #{cpu_gpu_spec_url}")
      {:ok, %HTTPoison.Response{status_code: 422, body: body}} ->
        Logger.error("[Workflow.SendMachineSpecs] #{body}")
      {:ok, %HTTPoison.Response{status_code: 401}} ->
        Logger.error("[Workflow.SendMachineSpecs] Invalid API_CODE")
      other ->
        IO.inspect "DEBUG #{__ENV__.file} @#{__ENV__.line}"
        IO.inspect other
        IO.inspect "END"
    end
  end

  def get_cpu_name() do
    {lscpu_output, _status} = System.cmd("lscpu", ["-J"])
    parse_cpu_name(lscpu_output)
  end

  def get_ram_size() do
    {free_output, _status} = System.cmd("free", ["-g"])
    parse_ram_size(free_output)
  end

  def get_motherboard_name() do
    {board_vendor, _status} =    System.cmd("cat", ["/sys/devices/virtual/dmi/id/board_vendor"])
    {board_name, _status} =      System.cmd("cat", ["/sys/devices/virtual/dmi/id/board_name"])
    {board_version, _status} =   System.cmd("cat", ["/sys/devices/virtual/dmi/id/board_version"])
    "#{board_vendor} #{board_name} #{board_version}"
  end

  def get_gpu_name_map() do
    if File.exists?("/usr/bin/nvidia-smi") do
      {nvidia_smi_output, _s} = System.cmd "nvidia-smi", ["--query-gpu=name", "--format=csv"]
      parse_gpu_map(nvidia_smi_output, :nvidia)
    else
      %{}
    end
  end



  @doc """
  parse_motherboard_name/1 do parse json output from `lscpu -J` command
  """
  def parse_cpu_name(lscpu_output) do
    Jason.decode!(lscpu_output)
    |> Map.get("lscpu")
    |> Enum.find(fn(e) ->
      Map.get(e, "field") == "Model name:"
    end)
    |> Map.get("data")
  end

  @doc """
  parse_ram_size/1 do parse json output from `free -g` command
  """
  def parse_ram_size(free_output) do
    memory_in_gb = free_output
    |> String.split("\n")
    |> Enum.at(1)
    |> String.split()
    |> Enum.at(1)
    "#{memory_in_gb}GB"
  end

  @doc """
  parse_gpu_map/2 do parse output from `nvidia-smi --query-gpu=name --format=csv` command.
  I dont have AMD cards. I can't test!
  """
  def parse_gpu_map(nvidia_smi_output, :nvidia) do
    nvidia_smi_output
    |> String.split("\n")
    |> Enum.drop(1)
    |> Enum.with_index(1)
    |> Enum.reduce(%{}, fn({gpu_name, index}, acc) ->
      if gpu_name == "" do
        acc
      else
        key = "gpu_#{index}_name" |> String.to_atom()
        Map.put(acc, key, gpu_name)
      end
    end)
  end

  def init_body_map() do
    %{
      cpu_name: nil,
      ram_size: nil,
      motherboard_name: nil,
      gpu_1_name: nil,
      gpu_2_name: nil,
      gpu_3_name: nil,
      gpu_4_name: nil,
      gpu_5_name: nil,
      gpu_6_name: nil,
      gpu_7_name: nil,
      gpu_8_name: nil
    }
  end
end
