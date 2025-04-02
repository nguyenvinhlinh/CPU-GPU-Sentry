defmodule CpuGpuSentry.MainWorkflow do

  def execute() do
    CpuGpuSentry.Workflow.SetupWrapperScript.execute()
    CpuGpuSentry.Workflow.FetchMiningPlaybookList.execute()
    CpuGpuSentry.Workflow.RemoveInvalidMiningPlaybookList.execute()
    CpuGpuSentry.Workflow.AddMiningPlaybookList.execute()
    CpuGpuSentry.Workflow.SetupMiningSoftware.execute()
  end
end
