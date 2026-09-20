defmodule TransitWatch.Routes.RouteParser do
  @moduledoc """
  A module for parsing route information from GTFS feeds.
  """

  alias TransitWatch.Routes.Routes
  alias TransitWatch.Agencies.Agencies
  alias TransitWatch.TransportModes.TransportModes

  def parse(file_path) do
    now = DateTime.truncate(DateTime.utc_now(), :microsecond)

    File.stream!(file_path)
    |> CSV.decode(headers: true)
    |> Enum.map(fn {:ok, row} ->
      %{
        gtfs_route_id: row["route_id"],
        gtfs_agency_id: row["agency_id"],
        route_short_name: row["route_short_name"],
        route_long_name: row["route_long_name"],
        route_desc: row["route_desc"],
        route_type: row["route_type"],
        route_url: row["route_url"],
        route_color: row["route_color"],
        route_text_color: row["route_text_color"],
        inserted_at: now,
        updated_at: now
      }
    end)
    |> find_agency
    |> find_transport_mode
    |> Routes.insert_all()
  end

  defp find_agency(route_maps) do
    Enum.map(route_maps, fn route ->
      gtfs_agency_id = Map.get(route, :gtfs_agency_id)

      agency = Agencies.get_by(gtfs_agency_id: gtfs_agency_id)

      route
      |> Map.put(:agency_id, agency.id)
      |> Map.delete(:gtfs_agency_id)
    end)
  end

  defp find_transport_mode(route_maps) do
    Enum.map(route_maps, fn route ->
      route_type = Map.get(route, :route_type)

      transport_mode = TransportModes.get_by(gtfs_route_type: route_type)
      IO.inspect(transport_mode, label: "TRANSPORT MODE")

      route
      |> Map.put(:transport_mode_id, transport_mode.id)
      |> Map.delete(:route_type)
    end)
  end
end
