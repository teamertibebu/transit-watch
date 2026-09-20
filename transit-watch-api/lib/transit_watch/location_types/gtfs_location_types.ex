defmodule TransitWatch.LocationTypes.GtfsLocationTypes do
  @moduledoc """
  GTFS base LocationType reference data.

  The values are based on the standard GTFS location_type enumeration.
  """

  alias TransitWatch.LocationTypes.LocationTypes

  @location_types [
    %{
      gtfs_locaton_type: 0,
      name: "Stop/Platform",
      desc:
        "A location where passengers board or disembark from a transit vehicle. Is called a platform when defined within a parent_station"
    },
    %{
      gtfs_locaton_type: 1,
      name: "Station",
      desc: "A physical structure or area that contains one or more platform."
    },
    %{
      gtfs_locaton_type: 2,
      name: "Entrance/Exit",
      desc:
        "A location where passengers can enter or exit a station from the street. If an entrance/exit belongs to multiple stations, it may be linked by pathways to both, but the data provider must pick one of them as parent."
    },
    %{
      gtfs_locaton_type: 3,
      name: "Generic Node",
      desc:
        "A location within a station, not matching any other location_type, that may be used to link together pathways defined in pathways.txt."
    },
    %{
      gtfs_locaton_type: 4,
      name: "Boarding Area",
      desc:
        "A specific location on a platform, where passengers can board and/or alight vehicles."
    }
  ]

  def all, do: @location_types

  def insert_all, do: LocationTypes.insert_all(@location_types)
end
