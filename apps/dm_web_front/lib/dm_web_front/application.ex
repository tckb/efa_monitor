defmodule EfaMonitor.DmFront.Web.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      EfaMonitor.DmFront.Web.Endpoint
    ]

    opts = [strategy: :one_for_one, name: EfaMonitor.DmFront.Web.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    EfaMonitor.DmFront.Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
