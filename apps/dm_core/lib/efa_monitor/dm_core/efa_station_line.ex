defmodule EfaMonitor.DmCore.EfaService.ServiceLine do
  alias EfaMonitor.DmCore.EfaService.ServiceLine
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
            line_number: 0,
            line_direction: nil,
            line_arrival_time: nil,
            line_arrival_time_actual: nil,
            line_start: nil,
            line_delayed_min: 0,
            line_arrival_platform_number: 0,
            line_arrival_platform_name: nil

  def get_line(departure_line) do
    arrival_time =
      case departure_line["servingLine"]["realTime"] do
        "1" ->
          Timex.to_datetime(
            {
              {
                departure_line["realDateTime"]["year"]
                |> String.to_integer(),
                departure_line["realDateTime"]["month"]
                |> String.to_integer(),
                departure_line["realDateTime"]["day"]
                |> String.to_integer()
              },
              {
                departure_line["realDateTime"]["hour"]
                |> String.to_integer(),
                departure_line["realDateTime"]["minute"]
                |> String.to_integer(),
                0
              }
            },
            Timex.Timezone.local()
          )

        rt when rt in ["0", nil] ->
          Timex.to_datetime(
            {
              {
                departure_line["dateTime"]["year"]
                |> String.to_integer(),
                departure_line["dateTime"]["month"]
                |> String.to_integer(),
                departure_line["dateTime"]["day"]
                |> String.to_integer()
              },
              {
                departure_line["dateTime"]["hour"]
                |> String.to_integer(),
                departure_line["dateTime"]["minute"]
                |> String.to_integer(),
                0
              }
            },
            Timex.Timezone.local()
          )
      end

    {actual_delay, actual_arrival_time} =
      case departure_line["servingLine"]["delay"] do
        d when d in [nil, "0"] ->
          {0, arrival_time}

        dl ->
          delay = String.to_integer(dl)
          {delay, Timex.shift(arrival_time, minutes: delay)}
      end

    %ServiceLine{
      line_name: departure_line["servingLine"]["name"],
      line_type: @transport_types[departure_line["servingLine"]["motType"]],
      line_number: departure_line["servingLine"]["number"],
      line_direction: departure_line["servingLine"]["direction"],
      line_start: departure_line["servingLine"]["directionFrom"],
      line_delayed_min: actual_delay,
      line_arrival_platform_number: departure_line["platform"],
      line_arrival_platform_name: departure_line["platformName"],
      line_arrival_time_actual: actual_arrival_time,
      line_arrival_time: arrival_time
    }
  end
end
