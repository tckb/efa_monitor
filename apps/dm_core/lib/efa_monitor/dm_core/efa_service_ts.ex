defmodule EfaMonitor.DmCore.TransportService do
  @moduledoc """
  the process responsible for calling the rest endpoint of the transport service. the process is especially calls the departure monitor endpoint and is not expected to call anyother api. the process works on 'async' calls, i.e., accepts only casts and will ignore any other messages

  the type specs is as follows:
  request:
    {pid, dm_request_type,DepartureMonitorHttpRequest.t }

  response:
    {dm_request_type, service_name, dm_response}

  """
  @type dm_request_type :: {:raw, :lines}
  @type service_name :: atom
  @type dm_response ::
          {:ok, map()}
          | {:error, :max_retries}
          | {:error, :station_not_found}
          | {:error, {:station_not_found, list_of_suggestions :: list(String.t())}}
          | {:error, reason :: binary}
  alias EfaMonitor.DmCore.ServiceLine
  alias EfaMonitor.DmCore.TransportService.DepartureMonitorHttpRequest, as: DMRequest
  require Logger
  use GenServer

  def start_link([], {service_name, {service_schema, service_host, service_api_path}}) do
    GenServer.start_link(
      __MODULE__,
      {service_name, service_schema, service_host, service_api_path},
      name: service_name
    )
  end

  @impl true
  def init({service_name, scheme, host, path}) do
    state = %{
      api_url: "#{scheme}://#{host}#{path}",
      service_name: service_name,
      requests: []
    }

    {:ok, state}
  end

  @impl true
  def handle_cast({dm_req = from, :raw, request = %DMRequest{}}, state) when is_pid(from) do
    state = %{state | requests: [from | state.requests]}
    {state, resp} = process_request(state, request)

    case resp do
      {:error, :retry} ->
        if request.retry_count > 0 do
          GenServer.cast(
            self(),
            {from, :raw, %{request | retry_count: request.retry_count - 1}}
          )
        else
          Logger.warn("Max retries exceeded, ignoring this message  #{inspect(dm_req)}")
          {:error, :max_retries}
        end

      _ ->
        GenServer.cast(from, {:raw, state.service_name, resp})
    end

    {:noreply, state}
  end

  @impl true
  def handle_cast(dm_req = {from, :lines, request = %DMRequest{}}, state) when is_pid(from) do
    state = %{state | requests: [from | state.requests]}

    {state, resp} = process_request(state, request)

    resp =
      case resp do
        {:ok, rawdata} ->
          Logger.info("got response")

          try do
            case get_lines(rawdata["dm"]["points"], rawdata["departureList"]) do
              {:error, station_suggestions} when is_list(station_suggestions) ->
                {:error, :station_not_found, station_suggestions}

              {:error, some_error} ->
                {:error, some_error}

              {:ok, lines} ->
                {:ok,
                 %{
                   station_name: rawdata["dm"]["points"]["point"]["name"],
                   station_service_alerts:
                     get_service_alerts(rawdata["dm"]["points"]["point"]["infos"]),
                   station_lines: lines
                 }}
            end
          rescue
            ArgumentError ->
              {:error, :station_not_found}
          end

        {:error, :retry} ->
          if request.retry_count > 0 do
            Logger.warn(fn -> "Last message failed, retrying #{inspect(request)}" end)

            GenServer.cast(
              self(),
              {from, :lines, %{request | retry_count: request.retry_count - 1}}
            )
          else
            Logger.warn(fn ->
              "Max retries exceeded, ignoring this message  #{inspect(dm_req)}"
            end)

            {:error, :max_retries}
          end

          nil

        {:error, some_error} ->
          {:error, some_error}
      end

    if resp != nil do
      Process.send(from, {:lines, state.service_name, resp}, [:noconnect])
    end

    {:noreply, state}
  end

  @impl true
  def handle_cast(_ignored_message, state) do
    # nothing to do here move on --
    {:noreply, state}
  end

  @impl true
  def handle_call(_ignored_message, _from, state) do
    # nothing to do here move on --
    {:noreply, state}
  end

  @impl true
  def handle_info({:mojito_response, nil, {:error, some_error}}, %{requests: []}) do
    Logger.error("Got error ignoring #{some_error}")
  end

  @impl true
  def handle_info({:mojito_response, nil, {:error, _}}, state) do
    [from | remain] = state.requests
    state = %{state | requests: remain}
    GenServer.cast(from, {:raw, state.service_name, {:error, :retry}})
    {:noreply, state}
  end

  @impl true
  def handle_info(message, state) do
    Logger.info(fn -> "Unexpected message  #{inspect(message)}" end)
    {:noreply, state}
  end

  defp process_request(state, request = %DMRequest{}) do
    resp =
      case Mojito.post(
             state.api_url,
             [{"Content-Type", "application/x-www-form-urlencoded"}],
             DMRequest.encode(request),
             opts: [
               transport_opts: [
                 verify: :verify_none
               ]
             ]
           ) do
        {:ok, resp = %Mojito.Response{status_code: 200}} ->
          Logger.debug("received response: #{inspect(resp)}")
          {:ok, Jason.decode!(resp.body)}

        {:ok, resp = %Mojito.Response{}} ->
          {:error, "Unexpected status code received: #{resp.status_code}"}

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

  defp get_lines(result_points, lines) when is_map(result_points) and not is_nil(lines) do
    {:ok,
     lines
     |> Enum.map(&ServiceLine.to_service_line/1)
     |> Enum.sort(fn l1, l2 ->
       Timex.compare(l1.line_arrival_time_actual, l2.line_arrival_time_actual, :minutes) < 0
     end)}
  end

  defp get_lines(result_points, _) when is_list(result_points) do
    {:error,
     result_points
     |> Enum.map(fn point -> point["name"] end)}
  end

  defp get_lines(_, _) do
    {:error, :station_not_found}
  end

  defp get_service_alerts(alert) when not is_nil(alert) and is_map(alert) do
    if alert["infoLinkText"] == nil do
      Logger.debug("got alert: #{inspect(alert)}")
    end

    alert_info = alert["infoText"]

    "#{alert["infoLinkText"]} ++ #{alert_info["subject"]} ++ #{alert_info["content"]} ++ #{
      alert_info["additionalText"]
    }"
  end

  defp get_service_alerts(_), do: ""
end
