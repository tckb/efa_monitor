defmodule EfaMonitor.DmFront.Web.DmLive.Request do
  use Ecto.Schema
  import Ecto.Changeset

  @supported_transport_regions Application.get_env(:dm_core, :api)
                               |> Map.keys()
                               |> Enum.map(&Atom.to_string/1)

  embedded_schema do
    field(:transport_region, :string)
    field(:search_station, :string)
  end

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, [:transport_region, :search_station])
    |> validate_required([:transport_region])
    |> validate_inclusion(:transport_region, @supported_transport_regions,
      message: "Not a valid transportation region!"
    )
  end
end

defmodule EfaMonitor.DmFront.Web.DmLive do
  use Phoenix.LiveView
  alias EfaMonitor.DmFront.Web.PageView
  alias EfaMonitor.DmCore.TransportService.ServiceConnector, as: TransportConnector
  alias EfaMonitor.DmFront.Web.DmLive.Request
  require Logger

  @request_freq_ms 30_000

  def render(assigns) do
    PageView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    Process.send_after(self(), :send_request, 100)
    Process.send_after(self(), :send_request, @request_freq_ms)

    {:ok,
     assign(socket,
       updated_time: Timex.now(),
       current_departures: %{
         station_lines: [],
         station_service_alerts: "Loading...",
         station_name: "Loading..."
       },
       changeset: Request.changeset(%{transport_region: "vrr", search_station: "Essen Hbf"}),
       current_request: %Request{transport_region: "vrr", search_station: "Essen Hbf"},
       waiting_for_response?: true
     )}
  end

  def handle_info({:lines, _service, {:ok, data}}, socket) do
    {:noreply,
     assign(socket,
       updated_time: Timex.local(),
       current_departures: data,
       waiting_for_response?: false
     )}
  end

  def handle_info({:lines, service, {:error, :station_not_found, station_suggestion}}, socket) do

    changeset =
      Request.changeset(%{
        transport_region: socket.assigns.current_request.transport_region,
        search_station: socket.assigns.current_request.search_station
      })
      |> Ecto.Changeset.add_error(
        :search_station,
        "Station not found, Did you mean one of these: " <> Enum.join(station_suggestion, " / ")
      )

    {:noreply,
     assign(socket,
       updated_time: Timex.local(),
       changeset: changeset,
       waiting_for_response?: false
     )}
  end

  def handle_info({:lines, _service, {:error, :station_not_found}}, socket) do
    changeset =
      Request.changeset(%{})
      |> Ecto.Changeset.add_error(
        :search_station,
        "Station not found!"
      )

    {:noreply,
     assign(socket,
       updated_time: Timex.local(),
       changeset: changeset,
       waiting_for_response?: false
     )}
  end

  def handle_info(:send_request, socket) do
    send_request(socket.assigns.current_request)
    Process.send_after(self(), :send_request, @request_freq_ms)
    {:noreply, socket}
  end

  def handle_event("validate", %{"search_form" => data}, socket) do
    changeset = data |> Request.changeset()
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event(
        "search",
        %{"search_form" => data},
        socket
      ) do
    changeset = data |> Request.changeset()
    Logger.info("saving changeset:#{inspect(changeset)}")

    if changeset.valid? do
      # send an  immediate request
      send_request(changeset.changes)

      {:noreply,
       assign(socket,
         current_request: %Request{
           transport_region: changeset.changes.transport_region,
           search_station: changeset.changes.search_station
         },
         waiting_for_response?: true
       )}
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp send_request(%{search_station: station_name, transport_region: transport_region}) do
    Logger.info("sending request: #{transport_region} #{station_name}")
    TransportConnector.send_request(:lines, transport_region |> String.to_atom(), station_name)
  end
end
