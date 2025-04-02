defmodule CpuGpuSentry.Workflow.RemoveInvalidMiningPlaybookList do
  require Logger

  def execute() do
    exist_mining_playbook_map = CpuGpuSentry.MiningPlaybookStash.get_all()
    tmp_mining_playbook_map   = CpuGpuSentry.TemporaryMiningPlaybookStash.get_all()
    if compare_mining_playbook_map(exist_mining_playbook_map, tmp_mining_playbook_map) == true do
      Logger.info("[Workflow.RemoveInvalidMiningPlaybookList] Compare and found no invalid mining playbook")
    else
      Logger.info("[Workflow.RemoveInvalidMiningPlaybookList] Compare and found invalid mining playbook list")
    end
  end

  def compare_mining_playbook_map(map_1, map_2) do
    compared_keys = [:id, :software_name, :software_version, :module, :command_argument,
                     :algorithm_1, :algorithm_2, :coin_name_1, :coin_name_2]
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
    for {k, v} <- exist_mining_playbook_map do
      if Kernel.is_nil(v.port), do: Port.close(v.port)
    end
    CpuGpuSentry.MiningPlaybookStash.clear()
  end
end
