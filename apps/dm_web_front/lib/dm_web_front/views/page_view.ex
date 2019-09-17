defmodule EfaMonitor.DmFront.Web.PageView do
  use EfaMonitor.DmFront.Web, :view
  alias EfaMonitor.DmCore.ServiceLine, as: TransportLine
  alias EfaMonitor.DmFront.Router.Helpers, as: Routes

  @line_types %{
    "0" => {"train", "#003399"},
    "1" => {"directions_railway", "#007055"},
    "2" => {"subway", "#007055"},
    "3" => {"directions_subway", "#00a0dd"},
    "4" => {"tram", "#00a0dd"},
    "5" => {"directions_bus", "#cc3333"},
    "6" => {"directions_bus", "#f9ad35"},
    "7" => {"directions_bus", "#7a7a7a"},
    "8" => {"directions_boat", "#7a7a7a"},
    "9" => {"directions_boat", "#7a7a7a"},
    "10" => {"directions_car", "#7a7a7a"}
  }

  defp get_icon(line) do
    {line_icon, line_color} = @line_types[line.line_type_id]

    ~E"""
    <i class="material-icons md-36" style="vertical-align: bottom; color: <%=line_color %>"><%=line_icon %></i>
    """
    |> safe_to_string()
  end

  defp get_delay(%TransportLine{} = line) do
    mins =
      line.line_arrival_time_actual
      |> Timex.diff(Timex.now(), :minutes)
      |> abs

    current_situation =
      cond do
        mins == 0 ->
          ~E"""
          <span class="badge badge-success" data-toggle="popover"  title="Status" data-content="This line is gonna leave now!">Now</span>
          """
          |> safe_to_string()

        mins > 0 and mins <= 8 ->
          ~E"""
          <span class="badge badge-success" data-toggle="popover"  title="Status" data-content="This line <b>will</b> arrive in <%= mins %> mins"><%= mins %></span>
          """
          |> safe_to_string()

        true ->
          " "
      end

    delay_mins =
      cond do
        line.line_delayed_min > 0 ->
          ~E"""
          <span class="badge badge-pill badge-warning" data-toggle="popover"  title="Delay Alert" data-content="This line <b>was</b> delayed by <%= line.line_delayed_min %> mins"><%= line.line_delayed_min %></span>
          """
          |> safe_to_string()

        line.line_delayed_min < 0 ->
          ~E"""
          <span class="badge badge-pill badge-danger"><%= humanize line.line_status %></span>
          """
          |> safe_to_string()

        true ->
          " "
      end

    additional_info =
      if String.length(line.line_info) > 1 do
        ~E"""
          <i id="popup" data-html="true" data-container="body" data-trigger="hover" data-toggle="popover" data-placement="top" title="Line Alert" data-content="<%= line.line_info %>" class="material-icons md-36" style="vertical-align: bottom; color:  #003399;">info</i>
        """
        |> safe_to_string()
      else
        " "
      end

    current_situation <> " " <> delay_mins <> " " <> additional_info
  end
end
