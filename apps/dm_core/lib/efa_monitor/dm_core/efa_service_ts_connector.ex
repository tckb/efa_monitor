defmodule EfaMonitor.DmCore.TransportService.ServiceConnector do
  @moduledoc """
  The main enttypooint to the efa core. This is the mains service which is responsible to connect and dispatch the messages to the corresponding transport service process. The supported transport services are listed in the configuration
  """
  @type request_type :: {:raw, :lines}

  alias EfaMonitor.DmCore.TransportService.DepartureMonitorHttpRequest, as: DMRequest
  alias EfaMonitor.DmCore.TransportService.Supervisor, as: EfaServiceSupervisor
  use GenServer
  require Logger
  @service_config Application.get_env(:dm_core, :api)

  @doc """
  sends the request  to the corresponding transport service
  """
  @spec send_request(request_type, atom(), binary) :: :ok
  def send_request(type, transport_service, station_name) when is_binary(station_name) do
    send_request(type, transport_service, station_name, 0)
  end

  @spec send_request(request_type, atom(), binary, integer()) :: :ok
  def send_request(type, transport_service, station_name, timeOffset) do
    GenServer.cast(
      __MODULE__,
      {type,
       {self(), transport_service, %DMRequest{name_dm: station_name, timeOffset: timeOffset}}}
    )
    :ok
  end

  ###########

  def start_link([]) do
    GenServer.start_link(
      __MODULE__,
      [],
      name: __MODULE__
    )
  end

  @impl true
  def init([]) do
    {:ok, []}
  end

  @impl true
  def handle_cast({request_type, request = {from, transport_service, req = %DMRequest{}}}, state)
      when is_pid(from) do
    Logger.info("Got #{request_type} from #{inspect(from)} req: #{inspect(request)}")

    case find_service(transport_service) do
      {:ok, pid} ->
        GenServer.cast(pid, {from, request_type, req})
        {:noreply, state}

      {:error, some_error} ->
        GenServer.cast(from, {request_type, transport_service, {:error, some_error}})
        {:noreply, state}
    end
  end

  defp find_service(service) do
    case Process.whereis(service) do
      pid when is_pid(pid) ->
        {:ok, pid}

      nil ->
        if Map.has_key?(@service_config, service) do
          EfaServiceSupervisor.start_child(
            service,
            {@service_config[service].scheme, @service_config[service].host,
             @service_config[service].apis.dm}
          )
        else
          {:error, :noservice}
        end
    end
  end
end
