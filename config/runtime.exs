import Config

if config_env() == :prod do
  installation_path = System.get_env("CPU_GPU_SENTRY_INSTALLATION_PATH") ||
    raise """
    environment CPU_GPU_SENTRY_INSTALLATION_PATH is missing
    For example: /opt/cpu_gpu_sentry
    """
  config :cpu_gpu_sentry, :installation_path, installation_path

  mininig_rig_commander_api_url = System.get_env("MININIG_RIG_COMMANDER_API_URL") ||
    raise """
    environment MININIG_RIG_COMMANDER_API_URL is missing
    For example: "http://127.0.0.1:4000/api/v1"
    """
  config :cpu_gpu_sentry, :mininig_rig_commander_api_url, mininig_rig_commander_api_url

  api_code = System.get_env("API_CODE") ||
    raise """
    environment API_CODE is missing
    Find this information in Mining Rig Monitor while creating new CPU/GPU Miner
    For example: api_code_1
    """
  config :cpu_gpu_sentry, :api_code, api_code
end
