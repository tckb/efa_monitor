defmodule EfaMonitor.EfaCore.EfaService.TransportService do
  alias EfaMonitor.EfaCore.EfaService.TransportService.DepartureMonitorHttpRequest, as: DMRequest
  alias EfaMonitor.EfaCore.EfaService.ServiceLine
  use GenServer
  require Logger

  defstruct [:service_name, :scheme, :host, :api_path, requests: []]

  def start_link([], {service_name, {service_schema, service_host, service_api_path}}) do
    GenServer.start_link(
      __MODULE__,
      {service_name, service_schema, service_host, service_api_path},
      name: service_name
    )
  end

  @impl true
  def init({service_name, scheme, host, path}) do
    state = %__MODULE__{api_path: path, scheme: scheme, host: host, service_name: service_name}
    {:ok, state}
  end

  @impl true
  def handle_cast({from, :raw, request = %DMRequest{}}, state) do
    state = %{state | requests: [from | state.requests]}
    {state, resp} = process_request(state, request)
    GenServer.cast(from, {:raw, state.service_name, resp})
    {:noreply, state}
  end

  @impl true
  def handle_cast({from, :lines, request = %DMRequest{}}, state) do
    state = %{state | requests: [from | state.requests]}

    {state, resp} = process_request(state, request)

    resp = case resp do
      {:ok, rawdata} ->
        get_lines(rawdata["dm"]["points"], rawdata["departureList"])

      {something_else} ->
        something_else
    end

    GenServer.cast(from, {:lines, state.service_name, resp})
    {:noreply, state}
  end

  @impl true
  def handle_info(message, state) do
    Logger.info(inspect(state))
    [from | remain] = state.requests
    state = %{state | requests: remain}

    case message do
      {:mojito_response, nil, {:error, :closed}} ->
        GenServer.cast(from, {:raw, state.service_name, {:error, :retry}})
        {:noreply, state}
    end
  end

  defp process_request(state, request = %DMRequest{}) do
    resp =
      case Mojito.post(
             "#{state.scheme}://#{state.host}#{state.api_path}",
             [{"Content-Type", "application/x-www-form-urlencoded"}],
             DMRequest.encode(request),
             opts: [
               transport_opts: [
                 verify: :verify_none
               ]
             ]
           ) do
        {:ok, resp = %Mojito.Response{status_code: 200}} ->
          Logger.debug("received response #{inspect(resp)}")
          {:ok, Jason.decode!(resp.body)}

        {:ok, resp = %Mojito.Response{}} ->
          {:error, "Unexpected status code received: #{resp.status}"}

        {:error, error = %Mojito.Error{reason: :timeout}} ->
          Logger.error(fn -> "#{inspect(error)} occurred while sending request" end)
          {:error, :retry}

        {:error, error = %Mojito.Error{}} ->
          Logger.error(fn -> "#{inspect(error)} occurred while sending request" end)
          {:error, :retry}
      end

    [_ | remain] = state.requests
    state = %{state | requests: remain}
    {state, resp}
  end

  defp get_lines(result_points, _) when is_list(result_points) do
    {
      :error,
      :station_not_found,
      result_points
      |> Enum.map(fn point -> point["name"] end)
    }
  end

  defp get_lines(result_points, lines) when is_map(result_points) do
    {
      :ok,
      lines
      |> Enum.map(&ServiceLine.get_line/1)
      |> Enum.sort(
           fn l1, l2 ->
             Timex.compare(l1.line_arrival_time_actual, l2.line_arrival_time_actual, :minutes) < 0
           end
         )
    }
  end
end
