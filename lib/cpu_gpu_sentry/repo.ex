defmodule CpuGpuSentry.Repo do
  use Ecto.Repo,
    otp_app: :cpu_gpu_sentry,
    adapter: Ecto.Adapters.Postgres
end
