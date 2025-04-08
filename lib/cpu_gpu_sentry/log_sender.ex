defmodule CpuGpuSentry.LogSender do
  use GenServer
  require Logger
  @api_path "/cpu_gpu_miners/logs"


  def start_link(_args), do: CpuGpuSentry.LogSender.start_link()
  def start_link() do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    Logger.info("[CpuGpuSentry.LogSender] Started")
    {:ok, pid}
  end

  @impl true
  def init(_) do
    Process.send_after(__MODULE__, :execute_loop, 10_000)
    {:ok, nil}
  end

  @impl true
  def handle_info(:execute_loop, _state) do
    execute()
    Process.send_after(__MODULE__, :execute_loop, 5_000)
    {:noreply, nil}
  end

  def execute do
    Logger.info("[CpuGpuSentry.LogSender] execute")
    log = CpuGpuSentry.LogStash.get()
    |> Map.from_struct()

    mininig_rig_commander_api_url = Application.get_env(:cpu_gpu_sentry, :mininig_rig_commander_api_url)
    api_url = Path.join([mininig_rig_commander_api_url, @api_path])
    api_code = Application.get_env(:cpu_gpu_sentry, :api_code)

    header_list = [
      {"content-type", "application/json"},
      {"api_code", api_code}
    ]

    body = Jason.encode!(log)

    case HTTPoison.post(api_url, body, header_list) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Logger.info("[CpuGpuSentry.LogSender] Send log")
        {:ok}
      {:ok, %HTTPoison.Response{status_code: 401} } ->
        Logger.error("[Workflow.LogSender] Invalid API_CODE")
        {:error, 401}
      error ->
        IO.inspect error
        {:error}
    end
  end
end
