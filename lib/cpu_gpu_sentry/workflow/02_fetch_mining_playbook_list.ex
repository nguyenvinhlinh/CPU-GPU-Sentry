defmodule CpuGpuSentry.Workflow.FetchMiningPlaybookList do
  require Logger

  def execute() do
    CpuGpuSentry.TemporaryMiningPlaybookStash.clear()
    case fetch_mining_playbook_list() do
      {:ok, mining_playbook_list} ->
        Logger.info("[Workflow.FetchMiningPlaybookList] Inserted into TemporaryMiningPlaybookStash")
        for mining_playbook <- mining_playbook_list do
          CpuGpuSentry.TemporaryMiningPlaybookStash.insert(mining_playbook)
        end
      _else ->
        {:error, :fetch_mining_playbook_list}
    end
  end

  def fetch_mining_playbook_list() do
    api_code = Application.get_env(:cpu_gpu_sentry, :api_code)
    mininig_rig_commander_api_url = Application.get_env(:cpu_gpu_sentry, :mininig_rig_commander_api_url)
    url = Path.join([mininig_rig_commander_api_url, "cpu_gpu_miners/playbooks"])
    header_list = [
      {"content-type", "application/json"},
      {"api_code", api_code}
    ]
    option_list = CpuGpuSentry.HTTPoisonOption.option_list()

    case HTTPoison.get(url, header_list, option_list) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Logger.info("[Workflow.FetchMiningPlaybookList] Mining playbook list fetched")
        mining_playbook_list = Jason.decode!(body)
        {:ok, mining_playbook_list}
      {:ok, %HTTPoison.Response{status_code: 401}} ->
        Logger.error("[Workflow.FetchMiningPlaybookList] Invalid API_CODE")
        {:error, 401}
      error ->
        IO.inspect error
        {:error}
    end
  end

  def fetch_mining_playbook_module(mining_playbook_id) do
    api_code = Application.get_env(:cpu_gpu_sentry, :api_code)
    mininig_rig_commander_api_url = Application.get_env(:cpu_gpu_sentry, :mininig_rig_commander_api_url)
    url = Path.join([mininig_rig_commander_api_url, "cpu_gpu_miners/playbooks", "#{mining_playbook_id}", "module"])
    header_list = [
      {"content-type", "application/json"},
      {"api_code", api_code}
    ]

    case HTTPoison.get(url, header_list) do
      {:ok, %HTTPoison.Response{status_code: 200, body: binary_module}} ->

        {:ok, binary_module}
      {:ok, %HTTPoison.Response{status_code: 401} } ->
        Logger.error("[Workflow.FetchMiningPlaybookList] Invalid API_CODE")
        {:error, 401}
      error ->
        IO.inspect error
        {:error}
    end
  end

  def load_binary_module(module_name, module_binary) do
    module = String.to_atom(module_name)
    :code.load_binary(module, module, module_binary)
  end

end
