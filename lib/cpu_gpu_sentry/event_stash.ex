defmodule CpuGpuSentry.EventStash do
  use GenServer
  require Logger

  def start_link(_args), do: CpuGpuSentry.EventStash.start_link()
  def start_link() do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    pid_string = pid
    |> :erlang.pid_to_list()
    |> to_string()
    Logger.info("[CpuGpuSentry.EventStash] PID:#{pid_string} Started ")
    {:ok, pid}
  end

  def pop() do
    GenServer.call(__MODULE__, :pop)
  end

  def append(event) do
    GenServer.cast(__MODULE__, {:append, event})
  end

  @impl true
  def init(_args) do
    event_list = []
    {:ok, event_list}
  end

  @impl true
  def handle_cast({:append, event}, state) do
    new_state = state ++ [event]
    {:noreply, new_state}
  end

  @impl true
  def handle_call(:pop, _from, state) do
    if Kernel.length(state) == 0 do
      {:reply, nil, []}
    else
      [event | other_event_list] = state
      {:reply, event, other_event_list}
    end
  end
end
