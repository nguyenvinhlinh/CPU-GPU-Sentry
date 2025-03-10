defmodule CpuGpuSentry.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CpuGpuSentryWeb.Telemetry,
      CpuGpuSentry.Repo,
      {DNSCluster, query: Application.get_env(:cpu_gpu_sentry, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CpuGpuSentry.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: CpuGpuSentry.Finch},
      # Start a worker by calling: CpuGpuSentry.Worker.start_link(arg)
      # {CpuGpuSentry.Worker, arg},
      # Start to serve requests, typically the last entry
      CpuGpuSentryWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CpuGpuSentry.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CpuGpuSentryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
