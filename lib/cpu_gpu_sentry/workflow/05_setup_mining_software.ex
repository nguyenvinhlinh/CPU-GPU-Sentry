defmodule CpuGpuSentry.Workflow.SetupMiningSoftware do
  require Logger

  def execute() do
    exist_mining_playbook_map = CpuGpuSentry.MiningPlaybookStash.get_all()

    for {_key, playbook} <- exist_mining_playbook_map do
      if playbook.current_status == :new do
        Logger.info("[Workflow.SetupMiningSoftware] Setup playbook ID:#{playbook.id} #{playbook.software_name} #{playbook.software_version}")
        Kernel.apply(playbook.module, :setup, [])

        playbook_mod = Map.put(playbook, :current_status, :stop)
        CpuGpuSentry.MiningPlaybookStash.insert(playbook_mod)
      else
        Logger.info("[Workflow.SetupMiningSoftware] Skip setting up playbook ID:#{playbook.id} #{playbook.software_name} #{playbook.software_version}")
      end
    end
  end

end
