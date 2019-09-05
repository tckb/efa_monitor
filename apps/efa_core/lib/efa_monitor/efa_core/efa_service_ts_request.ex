defmodule EfaMonitor.EfaCore.EfaService.TransportService.DepartureMonitorHttpRequest do
  alias EfaMonitor.EfaCore.EfaService.TransportService.DepartureMonitorHttpRequest

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
