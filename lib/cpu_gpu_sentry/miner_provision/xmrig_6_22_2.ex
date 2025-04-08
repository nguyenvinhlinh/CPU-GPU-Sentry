defmodule MinerProvision.XMRIG_6_22_2 do
 # @behaviour Miners.GenericMiner
  require Logger
  alias HTTPoison.Response

  @url "https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz"
  @miner_archive_filename "xmrig-6.22.2-linux-static-x64.tar.gz"
  @xmrig_api_path "/2/summary"
  @xmr_monitor_port "10001"

  #@impl Miners.GenericMiner
  def setup do
    if is_miner_archive_download?() == false do
      download_miner_archive()
    else
      Logger.info("[XMRIG_6_22_2] Skip downloading #{@miner_archive_filename}")
    end

    if is_miner_software_extract?() == false do
      extract_miner_archive()
    else
      Logger.info("[XMRIG_6_22_2] Skip extracting")
    end
  end

  #  @impl Miners.GenericMiner
  def start_mining(args_list) when Kernel.is_list(args_list) do
    installation_path = Application.get_env(:cpu_gpu_sentry, :installation_path)
    wrapper_script_path = Path.join([installation_path, "miner_softwares", "wrapper.sh"])
    xmrig_file_path =     Path.join([installation_path, "miner_softwares", "xmrig-6.22.2", "xmrig"])

    mod_args_list = [xmrig_file_path] ++ args_list ++ ["--http-port", @xmr_monitor_port]
    port = Port.open({:spawn_executable, wrapper_script_path}, [:binary, args: mod_args_list])
    port
  end

  def is_miner_archive_download?() do
    miner_archive_file_path = Path.join(["/tmp", @miner_archive_filename])
    File.exists?(miner_archive_file_path)
  end

  def download_miner_archive() do
    miner_archive_file_path = Path.join(["/tmp", @miner_archive_filename])
    with {:ok, %Response{status_code: 200, body: data}} <- http_get(@url),
         :ok <- write_file(miner_archive_file_path, data) do
      {:ok, miner_archive_file_path}
    else
      error ->
        IO.inspect "DEBUG #{__ENV__.file} @#{__ENV__.line}"
        IO.inspect error
        IO.inspect "END"
        error
    end
  end

  def is_miner_software_extract?() do
    installation_path = Application.get_env(:cpu_gpu_sentry, :installation_path)
    xmrig_file_path = Path.join([installation_path, "miner_softwares", "xmrig-6.22.2", "xmrig"])
    File.exists?(xmrig_file_path)
  end

  def extract_miner_archive() do
    miner_archive_file_path = Path.join(["/tmp", @miner_archive_filename])
    installation_path = Application.get_env(:cpu_gpu_sentry, :installation_path)
    miner_softwares_directory = Path.join([installation_path, "miner_softwares"])
    Logger.info("[XMRIG_6_22_2] Extract file #{miner_archive_file_path} to #{miner_softwares_directory}")
    :erl_tar.extract(miner_archive_file_path, [{:cwd, miner_softwares_directory}, :compressed])
  end

  def get_hashrate_summary() do
    url = Path.join(["127.0.0.1:10001", @xmrig_api_path])
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_xmrig_summary(body)
      _ ->
        Logger.error("[XMRIG_6_22_2] Cannot get xmrig summary #{url}")
        %MinerProvision.HashrateSummary{}
    end
  end


  def parse_xmrig_summary(json_string) do
    xmrig_summary_map = json_string
    |> Jason.decode!()

    cpu_hashrate = xmrig_summary_map
    |> Map.get("hashrate")
    |> Map.get("total")
    |> Enum.at(0)

    cpu_hashrate_mod = if(cpu_hashrate == nil, do: nil, else: Kernel.ceil(cpu_hashrate))

    %MinerProvision.HashrateSummary{
      cpu_hashrate_uom: "H/s",
      cpu_hashrate: cpu_hashrate_mod
    }
  end

  defp http_get(url) do
    Logger.info("[XMRIG_6_22_2] Downloading #{url}")
    HTTPoison.get(url, [], follow_redirect: true)
  end

  defp write_file(saved_path_filename, data) do
    Logger.info("[XMRIG_6_22_2] Writing to #{saved_path_filename}")
    File.write(saved_path_filename, data)
  end

  # debug only
  def test_start_mining() do
    args_list = [
      "--no-color",
      "--url", "pool.hashvault.pro:443",
      "--algo", "rx/0",
      "--user", "49gTVubHUbS4QqceSqLQ57LTf7K1eqdipKikuwiLUWx3CHUf2qCsRDX4jSV465we65Uv5k7D3YPtNfBGKv981PZYPkrhWLg",
      "--pass", "miner_name_X"
    ]

    start_mining(args_list)
  end

  # debug only
  def test_print_miner_logs() do
    receive do
      {_, {:data, msg}} ->
        IO.write(msg)
    after
      5000 ->
        IO.puts(:stderr, "5 seconds is over!")
    end
  end
end
