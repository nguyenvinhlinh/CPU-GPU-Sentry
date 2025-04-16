defmodule CpuGpuSentry.HTTPoisonOption do
  def option_list do
    case Application.get_env(:cpu_gpu_sentry, :mining_rig_monitor_server_name) do
      nil ->
        [
          {:ssl,  [
              {:cacerts, :public_key.cacerts_get()}
            ]}
        ]
      mining_rig_monitor_server_name ->
        mining_rig_monitor_server_name_charlist = String.to_charlist(mining_rig_monitor_server_name)
        [
          {:ssl,  [
              {:cacerts, :public_key.cacerts_get()},
              {:server_name_indication, mining_rig_monitor_server_name_charlist}
            ]}
        ]
    end
  end
end
