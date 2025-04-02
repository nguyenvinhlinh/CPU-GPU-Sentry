defmodule CpuGpuSentry.MainWorkflow do

  def execute() do
    CpuGpuSentry.Workflow.SetupWrapperScript.execute()
    CpuGpuSentry.Workflow.FetchMiningPlaybookList.execute()
  end
end
