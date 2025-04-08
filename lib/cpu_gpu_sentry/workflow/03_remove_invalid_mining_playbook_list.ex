defmodule CpuGpuSentry.Workflow.RemoveInvalidMiningPlaybookList do
  require Logger

  def execute() do
    exist_mining_playbook_map = CpuGpuSentry.MiningPlaybookStash.get_all()
    tmp_mining_playbook_map   = CpuGpuSentry.TemporaryMiningPlaybookStash.get_all()
    if compare_mining_playbook_map(exist_mining_playbook_map, tmp_mining_playbook_map) == true do
      Logger.info("[Workflow.RemoveInvalidMiningPlaybookList] Compare and found no invalid mining playbook")
    else
      Logger.info("[Workflow.RemoveInvalidMiningPlaybookList] Compare and found invalid mining playbook list")
      remove_invalid_mining_playbook_list()
    end
  end

  def compare_mining_playbook_map(map_1, map_2) do
    compared_keys = [:id, :software_name, :software_version, :module, :command_argument,
                     :cpu_coin_name, :cpu_algorithm,
                     :gpu_coin_name_1, :gpu_algorithm_1,
                     :gpu_coin_name_2, :gpu_algorithm_2]
    map_1_mod = Enum.reduce(map_1, %{}, fn(e, a) ->
      {k, v} = e
      Map.put(a, k, Map.take(v, compared_keys))
    end)
    map_2_mod = Enum.reduce(map_2, %{}, fn(e, a) ->
      {k, v} = e
      Map.put(a, k, Map.take(v, compared_keys))
    end)
    map_1_mod == map_2_mod
  end

  def remove_invalid_mining_playbook_list() do
    exist_mining_playbook_map = CpuGpuSentry.MiningPlaybookStash.get_all()
    for {playbook_id, _v} <- exist_mining_playbook_map do
      CpuGpuSentry.PortProcessRunner.stop(playbook_id)
    end
    CpuGpuSentry.MiningPlaybookStash.clear()
  end
end
