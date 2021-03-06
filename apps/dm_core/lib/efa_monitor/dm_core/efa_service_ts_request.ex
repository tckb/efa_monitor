defmodule EfaMonitor.DmCore.TransportService.DepartureMonitorHttpRequest do
  @moduledoc """
  the departure monitoring request
  """
  @type t :: %__MODULE__{
          name_dm: binary,
          timeOffset: pos_integer,
          language: String.t(),
          type_dm: String.t(),
          mode: String.t(),
          useAllStops: 0..1,
          depType: String.t(),
          includeCompleteStopSeq: 0..1,
          useRealtime: 0..1,
          outputFormat: String.t(),
          lineRestriction: pos_integer()
          # itdDate: String.t()
        }
  alias EfaMonitor.DmCore.TransportService.DepartureMonitorHttpRequest

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
            lineRestriction: 400,
            # itdDate: "20190928",
            retry_count: 5

  @doc """
  encodes the current request into url-encoded string
  """
  @spec encode(DepartureMonitorHttpRequest.t()) :: String.t()
  def encode(req = %DepartureMonitorHttpRequest{}) do
    req
    |> Map.from_struct()
    |> Enum.filter(fn {k, _} -> k != "retry_count" end)
    |> Enum.map(fn {k, v} ->
      "#{k}=#{v}"
      |> URI.encode()
    end)
    |> Enum.join("&")
  end
end
