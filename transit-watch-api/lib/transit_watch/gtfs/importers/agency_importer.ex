defmodule TransitWatch.GTFS.Importers.AgencyImporter do
  @moduledoc """
  A module for parsing basic agency information from GTFS feeds.
  """

  alias TransitWatch.GTFS

  def import(file_path) do
    now = DateTime.truncate(DateTime.utc_now(), :microsecond)

    File.stream!(file_path)
    |> CSV.decode(headers: true)
    |> Enum.map(fn {:ok, row} ->
      %{
        gtfs_agency_id: row["agency_id"],
        name: row["agency_name"],
        main_url: row["agency_url"],
        fare_url: row["agency_fare_url"],
        timezone: row["agency_timezone"],
        phone: row["agency_phone"],
        inserted_at: now,
        updated_at: now
      }
    end)
    |> GTFS.insert_all_agencies()
  end
end
