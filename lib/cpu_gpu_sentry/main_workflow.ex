defmodule CpuGpuSentry.MainWorkflow do
  use GenServer
  require Logger

  def start_link(_args), do: CpuGpuSentry.MainWorkflow.start_link()
  def start_link() do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    Logger.info("[MainWorkflow] Started")
    {:ok, pid}
  end

  @impl true
  def init(_args) do
    Process.send_after(__MODULE__, :execute_once, 1000)
    Process.send_after(__MODULE__, :execute_loop, 2000)
    {:ok, nil}
  end

  @impl true
  def handle_info(:execute_loop, _state) do
    execute()
    Process.send_after(__MODULE__, :execute_loop, 60_000)
    {:noreply, nil}
  end

  @impl true
  def handle_info(:execute_once, _state) do
    execute_once()
    {:noreply, nil}
  end

  def execute() do
    CpuGpuSentry.Workflow.FetchMiningPlaybookList.execute()
    CpuGpuSentry.Workflow.RemoveInvalidMiningPlaybookList.execute()
    CpuGpuSentry.Workflow.AddMiningPlaybookList.execute()
    CpuGpuSentry.Workflow.SetupMiningSoftware.execute()
    CpuGpuSentry.Workflow.StartMiningSoftware.execute()
  end

  def execute_once() do
    CpuGpuSentry.Workflow.SetupWrapperScript.execute()
    CpuGpuSentry.Workflow.SendMachineSpecs.execute()
  end
end
