defmodule EfaMonitor.DmCore.Application do
  @moduledoc false
  use Application

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    children = [
      {EfaMonitor.DmCore.EfaService.TransportService.Supervisor, []},
      {EfaMonitor.DmCore.EfaService.TransportService.ServiceConnector, []}
    ]

    opts = [strategy: :one_for_one, name: EfaMonitor.DmCore.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
