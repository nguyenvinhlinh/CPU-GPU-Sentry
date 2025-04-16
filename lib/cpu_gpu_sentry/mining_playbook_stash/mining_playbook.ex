defmodule CpuGpuSentry.MiningPlaybookStash.MiningPlaybook do
  defstruct [:id, :software_name, :software_version, :module, :command_argument,
             :cpu_coin_name, :gpu_coin_name_1, :gpu_coin_name_2,
             :cpu_algorithm, :gpu_algorithm_1, :gpu_algorithm_2,
             :cpu_pool_address, :gpu_pool_address_1, :gpu_pool_address_2,
             :cpu_wallet_address, :gpu_wallet_address_1, :gpu_wallet_address_2,
             :expected_status, :current_status, :inserted_at, :updated_at]

  @current_status_new    :new
  @current_status_stop   :stop
  @current_status_mining :mining

  def current_status_new(), do: @current_status_new
  def current_status_stop(), do: @current_status_stop
  def current_status_mining(), do: @current_status_mining
end
