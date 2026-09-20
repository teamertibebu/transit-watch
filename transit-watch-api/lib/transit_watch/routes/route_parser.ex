defmodule TransitWatch.Routes.RouteParser do
  @moduledoc """
  Parses GTFS Route data, sets necessary associations, and persists.
  """

  alias TransitWatch.Routes.Routes
  alias TransitWatch.Agencies.Agencies
  alias TransitWatch.TransportModes.TransportModes

  def parse(file_path) do
    now = DateTime.truncate(DateTime.utc_now(), :microsecond)

    agencies = list_agencies()
    transport_modes = list_transport_modes()

    file_path
    |> File.stream!()
    |> CSV.decode(headers: true)
    |> Enum.map(fn {:ok, row} ->
      to_route_attrs(row, agencies, transport_modes, now)
    end)
    |> Routes.insert_all()
  end

  defp to_route_attrs(row, agencies, transport_modes, now) do
    %{
      gtfs_route_id: row["route_id"],
      agency_id: Map.fetch!(agencies, row["agency_id"]),
      transport_mode_id: Map.fetch!(transport_modes, row["route_type"]),
      route_short_name: row["route_short_name"],
      route_long_name: row["route_long_name"],
      route_desc: row["route_desc"],
      route_url: row["route_url"],
      route_color: row["route_color"],
      route_text_color: row["route_text_color"],
      inserted_at: now,
      updated_at: now
    }
  end

  defp list_agencies do
    Agencies.list_all()
    |> Map.new(fn agency -> {agency.gtfs_agency_id, agency.id} end)
  end

  defp list_transport_modes do
    TransportModes.list_all()
    |> Map.new(fn mode -> {mode.gtfs_route_type, mode.id} end)
  end
end
