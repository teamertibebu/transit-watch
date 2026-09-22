defmodule TransitWatch.GTFS.Importers.StopImporter do
  @moduledoc """
  A module for parsing Stop information from GTFS feeds.
  """

  alias TransitWatch.GTFS

  def import(file_path) do
    now = DateTime.truncate(DateTime.utc_now(), :microsecond)

    File.stream!(file_path)
    |> CSV.decode(headers: true)
    |> Stream.map(&to_stop_attrs(&1, now))
    |> Stream.chunk_every(1_000)
    |> Enum.each(fn stop_batch ->
      GTFS.insert_all_stops(stop_batch)
    end)
  end

  defp to_stop_attrs({:ok, row}, now) do
    location_types =
      Map.new(GTFS.list_location_types(), fn location_type ->
        {location_type.gtfs_locaton_type, location_type.id}
      end)

    ## The GTFS specification allows for location_type to be set to either 0 or
    ## left empty when type is Stop/Platform.
    gtfs_location_type =
      if row["location_type"] == "", do: 0, else: String.to_integer(row["location_type"])

    parent_station =
      if row["parent_station"] == "", do: nil, else: String.to_integer(row["parent_station"])

    %{
      gtfs_stop_id: String.to_integer(row["stop_id"]),
      code: row["stop_code"],
      name: row["stop_name"],
      desc: row["stop_desc"],
      lat: String.to_float(row["stop_lat"]),
      long: String.to_float(row["stop_lon"]),
      url: row["stop_url"],
      parent_station: parent_station,
      wheelchair_boarding: String.to_integer(row["wheelchair_boarding"]),
      location_type_id: Map.get(location_types, gtfs_location_type),
      inserted_at: now,
      updated_at: now
    }
  end
end
