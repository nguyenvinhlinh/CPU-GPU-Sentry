defmodule CpuGpuSentry.PortProcessRunner do
  use GenServer
  require Logger

  defmodule State do
    defstruct [:playbook_id, :port]
  end

  def start_link(playbook_id) do
    name = "port_process_runner_#{playbook_id}" |> String.to_atom()
    {:ok, pid} = GenServer.start_link(__MODULE__, playbook_id, name: name)
    Logger.info("[PortProcessRunner][#{playbook_id}] Started")
    {:ok, pid}
  end

  def stop(playbook_id) do
    name = "port_process_runner_#{playbook_id}" |> String.to_atom()
    GenServer.stop(name)
  end

  @impl true
  def init(playbook_id) do
    state = %State{
      playbook_id: playbook_id,
      port: nil
    }
    process_name = "port_process_runner_#{playbook_id}" |> String.to_atom()
    Process.send_after(process_name, :execute, 5000)

    {:ok, state}
  end

  @impl true
  def handle_info(:execute, %State{}=state) do
    Logger.info("[PortProcessRunner][#{state.playbook_id}] execute")
    mining_playbook = CpuGpuSentry.MiningPlaybookStash.get(state.playbook_id)
    args_list = String.split(mining_playbook.command_argument, " ")
    port = Kernel.apply(mining_playbook.module, :start_mining, [args_list])

    new_state = %{
      playbook_id: state.playbook_id,
      port: port
    }

    {:noreply, new_state}
  end

  @impl true
  def handle_info({_port, {:data, message}}, state) do
    IO.write(message)
    {:noreply, state}
  end

  @impl true
  def handle_info(message, state) do
    IO.inspect "DEBUG #{__ENV__.file} @#{__ENV__.line}"
    IO.inspect message
    IO.inspect "END"
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, state) do
    if Kernel.is_nil(state.port) do
      Logger.info("[PortProcessRunner][#{state.playbook_id}] Skip closing port because it's nil")

    else
      Logger.info("[PortProcessRunner][#{state.playbook_id}] Close port")
      Port.close(state.port)
    end

    mining_playbook = CpuGpuSentry.MiningPlaybookStash.get(state.playbook_id)
    new_mining_playbook = Map.put(mining_playbook, :current_status, :stop)
    CpuGpuSentry.MiningPlaybookStash.insert(new_mining_playbook)
  end
end
