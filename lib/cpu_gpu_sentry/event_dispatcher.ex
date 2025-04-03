defmodule CpuGpuSentry.EventDispatcher do
  use GenServer
  require Logger
  alias CpuGpuSentry.EventStash

  def start_link(_args), do: CpuGpuSentry.EventDispatcher.start_link()
  def start_link() do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    pid_string = pid
    |> :erlang.pid_to_list()
    |> to_string()
    Logger.info("[CpuGpuSentry.EventDispatcher] PID:#{pid_string} Started")
    Process.send_after(pid, :interval_function, 5_000)
    {:ok, pid}
  end

  @impl true
  def init(_args) do
    {:ok, nil}
  end

  @impl true
  def handle_info(:interval_function, _state) do
    interval_function()
    {:noreply, nil}
  end

  def interval_function() do
    Logger.info("[CpuGpuSentry.EventDispatcher] interval_function")
    event = EventStash.pop()

    case event do
      :shutdown ->
        Logger.info("[CpuGpuSentry.EventDispatcher] Event Shutdown")
      :restart ->
        Logger.info("[CpuGpuSentry.EventDispatcher] Event Restart")
      _else ->
        :ok
    end
  end
end
