defmodule CpuGpuSentry.MiningPlaybookStash.MiningPlaybook do
  defstruct [:id, :software_name, :software_version, :module, :command_argument,
             :algorithm_1, :algorithm_2, :coin_name_1, :coin_name_2,
             :expected_status, :current_status, :inserted_at, :updated_at]

  @current_status_new    :new
  @current_status_stop   :stop
  @current_status_mining :mining

  def current_status_new(), do: @current_status_new
  def current_status_stop(), do: @current_status_stop
  def current_status_mining(), do: @current_status_mining
end
