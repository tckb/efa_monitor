defmodule EfaMonitor.DmCore.EfaService.TransportService.DepartureMonitorHttpRequest do
  @moduledoc """
  the departure monitoring request
  """
  alias EfaMonitor.DmCore.EfaService.TransportService.DepartureMonitorHttpRequest

  defstruct name_dm: nil,
            timeOffset: 0,
            language: "de",
            type_dm: "stop",
            mode: "direct",
            useAllStops: 1,
            depType: "STOPEVENTS",
            includeCompleteStopSeq: 0,
            useRealtime: 1,
            outputFormat: "json",
            lineRestriction: 400

  @doc """
  encodes the current request into url-encoded string
  """
  @spec encode(DepartureMonitorHttpRequest.t()) :: binary
  def encode(req = %DepartureMonitorHttpRequest{}) do
    req
    |> Map.from_struct()
    |> Enum.map(fn {k, v} ->
      "#{k}=#{v}"
      |> URI.encode()
    end)
    |> Enum.join("&")
  end
end
