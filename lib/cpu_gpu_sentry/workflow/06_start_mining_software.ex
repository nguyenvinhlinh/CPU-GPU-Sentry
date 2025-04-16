defmodule CpuGpuSentry.Workflow.StartMiningSoftware do
  require Logger

  def execute() do
    exist_mining_playbook_map = CpuGpuSentry.MiningPlaybookStash.get_all()

    for {_key, playbook} <- exist_mining_playbook_map do
      if playbook.expected_status == :mining and playbook.current_status == :stop do
        Logger.info("[Workflow.StartMiningSoftware] Start playbook ID:#{playbook.id} #{playbook.software_name} #{playbook.software_version}")

        CpuGpuSentry.PortProcessRunner.start_link(playbook.id)
        mod_playbook = playbook
        |> Map.put(:current_status, :mining)
        CpuGpuSentry.MiningPlaybookStash.insert(mod_playbook)
      else
        Logger.info("[Workflow.StartMiningSoftware] Skip start playbook ID:#{playbook.id} #{playbook.software_name} #{playbook.software_version}")
      end
    end
  end

end
