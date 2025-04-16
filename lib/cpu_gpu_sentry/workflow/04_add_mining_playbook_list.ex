defmodule CpuGpuSentry.Workflow.AddMiningPlaybookList do
  require Logger

  def execute() do
    exist_mining_playbook_map = CpuGpuSentry.MiningPlaybookStash.get_all()
    tmp_mining_playbook_map = CpuGpuSentry.TemporaryMiningPlaybookStash.get_all()

    if exist_mining_playbook_map == %{} do
      for {_key, playbook} <- tmp_mining_playbook_map  do
        Logger.info("[Workflow.AddMiningPlaybookList] Added mining playbook ID:#{playbook.id} #{playbook.software_name} #{playbook.software_version}")
        playbook_mod = playbook
        |> Map.put(:current_status, :new)
        CpuGpuSentry.MiningPlaybookStash.insert(playbook_mod)
      end
    else
      Logger.info("[Workflow.AddMiningPlaybookList] Skip adding mining playbook list")
    end
  end
end
