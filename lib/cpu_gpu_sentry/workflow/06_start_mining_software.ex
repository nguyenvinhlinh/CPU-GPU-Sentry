defmodule CpuGpuSentry.Workflow.StartMiningSoftware do
  require Logger

  def execute() do
    exist_mining_playbook_map = CpuGpuSentry.MiningPlaybookStash.get_all()
    
  end

end
