defmodule EfaMonitor.DmCore.ServiceLine do
  @moduledoc """
  a structure respresenting the service line operating at a particular station.
  """

  @typedoc """
  the line type is as following:

  Zug,S-Bahn,U-Bahn,Stadtbahn,
  Straßenbahn,Bus,Regionalbus,
  Schnellbus,Schiff,Seil-/Zahnradbahn,Ruftaxi

  """
  @type t :: %__MODULE__{
          line_name: String.t(),
          line_type: String.t(),
          line_type_id: String.t(),
          line_number: pos_integer,
          line_direction: String.t(),
          line_arrival_time: DateTime.t(),
          line_arrival_time_actual: DateTime.t(),
          line_start: String.t(),
          line_delayed_min: pos_integer,
          line_arrival_platform_number: pos_integer,
          line_arrival_platform_name: String.t(),
          line_info: String.t(),
          line_status: String.t()
        }
  require Logger

  @transport_types %{
    "0" => "Zug",
    "1" => "S-Bahn",
    "2" => "U-Bahn",
    "3" => "Stadtbahn",
    "4" => "Straßenbahn",
    "5" => "Bus",
    "6" => "Regionalbus",
    "7" => "Schnellbus",
    "8" => "Schiff",
    "9" => "Seil-/Zahnradbahn",
    "10" => "Ruftaxi"
  }

  defstruct line_name: nil,
            line_type: nil,
            line_type_id: 0,
            line_number: 0,
            line_direction: nil,
            line_arrival_time: nil,
            line_arrival_time_actual: nil,
            line_start: nil,
            line_delayed_min: 0,
            line_arrival_platform_number: 0,
            line_arrival_platform_name: nil,
            line_info: "",
            line_status: nil

  @doc """
  converts the departure line into the serving line
  """
  @spec to_service_line(departure_line :: map()) :: __MODULE__.t()
  def to_service_line(departure_line) do
    serving_line = departure_line["servingLine"]

    datetime =
      case departure_line["realTime"] do
        "1" -> departure_line["realDateTime"]
        rt when rt in ["0", nil] -> departure_line["dateTime"]
      end

    arrival_time =
      with year when year > 0 <- String.to_integer(datetime["year"]),
           month when month > 0 <- String.to_integer(datetime["month"]),
           day when day > 0 <- String.to_integer(datetime["day"]),
           hour when hour >= 0 <- String.to_integer(datetime["hour"]),
           minute when minute >= 0 <- String.to_integer(datetime["minute"]) do
        Timex.to_datetime({{year, month, day}, {hour, minute, 0}}, :local)
      else
        _ ->
          Logger.error(fn ->
            "Bad timedata received from upstream, attempted to convert datatime from #{datetime}"
          end)

          DateTime.utc_now()
      end

    {actual_delay, actual_arrival_time} =
      case serving_line["delay"] do
        d when d in [nil, "0"] ->
          {0, arrival_time}

        dl ->
          delay = String.to_integer(dl)
          {delay, Timex.shift(arrival_time, minutes: delay)}
      end

    %__MODULE__{
      line_name: serving_line["name"],
      line_type: @transport_types[serving_line["motType"]],
      line_type_id: serving_line["motType"],
      line_number: serving_line["number"],
      line_direction: serving_line["direction"],
      line_start: serving_line["directionFrom"],
      line_delayed_min: actual_delay,
      line_arrival_platform_number: departure_line["platform"],
      line_arrival_platform_name: departure_line["platformName"],
      line_arrival_time_actual: actual_arrival_time,
      line_arrival_time: arrival_time,
      line_info: get_service_alerts(departure_line["lineInfos"]),
      line_status: departure_line["realtimeStatus"]
    }
  rescue
    some_error ->
      Logger.error(fn ->
        "Error while conversion #{inspect(some_error)} for input #{inspect(departure_line)}"
      end)

      %__MODULE__{}
  end

  defp get_service_alerts(alerts) when not is_nil(alerts) and is_list(alerts) do
    alerts
    |> Enum.map(&get_service_alerts/1)
    |> Enum.filter(fn alert -> String.length(alert) > 0 end)
    |> Enum.join(" ++++ ")
  end

  defp get_service_alerts(alert = %{"lineInfo" => line_info})
       when not is_nil(alert) and is_map(alert) do
    get_service_alerts(line_info)
  end

  defp get_service_alerts(alert) when not is_nil(alert) and is_map(alert) do
    if alert["infoLinkText"] == nil do
      get_service_alerts(alert["info"])
    else
      Logger.debug("got get_service_alerts: #{inspect(alert)}")

      alert_info = alert["infoText"]

      "#{alert["infoLinkText"]} ++ #{alert_info["subject"]} ++ #{alert_info["content"]} ++ #{
        alert_info["additionalText"]
      }"
    end
  end

  defp get_service_alerts(_), do: ""
end
