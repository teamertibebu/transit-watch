defmodule TransitWatch.Agencies.AgencyParser do
  @moduledoc """
  A module for parsing basic agency information from Google's GTFS feed.
  """

  alias TransitWatch.Agencies.Agencies

  def parse(file_path) do
    File.stream!(file_path)
    |> CSV.decode(headers: true)
    |> Enum.map(fn {:ok, row} ->
      %{
        short_name: row["agency_id"],
        long_name: row["agency_name"],
        main_url: row["agency_url"],
        fare_url: row["agency_fare_url"],
        timezone: row["agency_timezone"],
        phone: row["agency_phone"]
      }
    end)
    |> Agencies.insert_all()
  end
end
