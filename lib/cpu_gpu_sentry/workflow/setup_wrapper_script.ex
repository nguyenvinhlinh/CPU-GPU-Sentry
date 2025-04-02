defmodule CpuGpuSentry.Workflow.SetupWrapperScript do
  require Logger
  use GenServer

  @wrapper_script_content """
  #!/usr/bin/env bash

  # Start the program in the background
  exec "$@" &
  pid1=$!

  # Silence warnings from here on
  exec >/dev/null 2>&1

  # Read from stdin in the background and
  # kill running program when stdin closes
  exec 0<&0 $(
    while read; do :; done
    kill -KILL $pid1
  ) &
  pid2=$!

  # Clean up
  wait $pid1
  ret=$?
  kill -KILL $pid2
  exit $ret
  """

  @doc """
  wrapper_script/0 function returns wrapper script referenced from Elixir's Port module.
  https://hexdocs.pm/elixir/Port.html#module-zombie-operating-system-processes
  """

  def execute() do
    if is_miner_software_directory_exists?() == false do
      mkdir_miner_software_directory()
    else
      Logger.info("[EventHandler.SetupWrapperScript] Skip making miner_software_directory")
    end

    if is_wrapper_script_exists?() == false do
      write_wrapper_script()
      chmod_wrapper_script()
    else
      Logger.info("[EventHandler.SetupWrapperScript] Skip writing wrapper.sh")
    end
  end

  def write_wrapper_script() do
    installation_path = Application.get_env(:cpu_gpu_sentry, :installation_path)
    wrapper_script_path = Path.join([installation_path, "miner_softwares", "wrapper.sh"])
    Logger.info("[EventHandler.SetupWrapperScript] Writing #{wrapper_script_path}")
    File.write(wrapper_script_path, @wrapper_script_content)
  end

  def is_wrapper_script_exists?() do
    installation_path = Application.get_env(:cpu_gpu_sentry, :installation_path)
    wrapper_script_path = Path.join([installation_path, "miner_softwares", "wrapper.sh"])
    File.exists?(wrapper_script_path)
  end

  def chmod_wrapper_script() do
    installation_path = Application.get_env(:cpu_gpu_sentry, :installation_path)
    wrapper_script_path = Path.join([installation_path, "miner_softwares", "wrapper.sh"])
    Logger.info("[EventHandler.SetupWrapperScript] Chmod #{wrapper_script_path} 755")
    File.chmod(wrapper_script_path, 0o755)
  end

  def mkdir_miner_software_directory() do
    installation_path = Application.get_env(:cpu_gpu_sentry, :installation_path)
    miner_software_path = Path.join([installation_path, "miner_softwares"])
    Logger.info("[EventHandler.SetupWrapperScript] Mkdir #{miner_software_path}")
    File.mkdir(miner_software_path)
  end

  def is_miner_software_directory_exists?() do
    installation_path = Application.get_env(:cpu_gpu_sentry, :installation_path)
    miner_software_path = Path.join([installation_path, "miner_softwares"])
    File.exists?(miner_software_path)
  end

end
