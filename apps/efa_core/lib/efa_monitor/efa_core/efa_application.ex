defmodule EfaMonitor.EfaCore.Application do
  @moduledoc false
  use Application
  def start(_type, _args) do
    children = [
      {EfaMonitor.EfaCore.EfaService.TransportService.Supervisor, []},
      {EfaMonitor.EfaCore.EfaService.TransportService.ServiceConnector, []}
    ]

    opts = [strategy: :one_for_one, name: EfaMonitor.EfaCore.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
