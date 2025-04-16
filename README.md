# CPU/GPU Sentry
This software will be installed on Crypto Currency Miner. It takes responsibility to
- Send machine spec (cpu/motherboard/ram/gpu) nvidia supported only.
- Fetch Mining PlayBook, support dual mining
- Run crypto currency miner program (xmrig, bzminer ...)
- Send hashrate/temperature

# Environment Variables
- `CPU_GPU_SENTRY_INSTALLATION_PATH`: a directory path which this software is installed, /opt/cpu_gpu_sentry/
- `MININIG_RIG_COMMANDER_API_URL`: for example `127.0.0.1:4000/api/v1`, `https://mrm.hexalink.xyz/api/v1`
- `API_CODE`: Find this information in Mining Rig Monitor while creating new CPU/GPU Miner
- `MINING_RIG_MONITOR_SERVER_NAME`: This option involve SSL certificate. ignore it if you dont use SSL or homebrew Certified Authority.
