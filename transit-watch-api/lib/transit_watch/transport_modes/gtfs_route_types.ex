defmodule TransitWatch.TransportModes.GtfsRouteTypes do
  @moduledoc """
  GTFS base route-type reference data.

  The values are based on the standard GTFS route_type enumeration.
  """

  alias TransitWatch.TransportModes.TransportModes

  @route_types [
    %{
      gtfs_route_type: 0,
      mode: "Tram, Streetcar, Light rail",
      description: "Any light rail or street-level system within a metropolitan area."
    },
    %{
      gtfs_route_type: 1,
      mode: "Subway, Metro",
      description: "Any underground rail system within a metropolitan area."
    },
    %{
      gtfs_route_type: 2,
      mode: "Rail",
      description: "Used for intercity or long-distance travel."
    },
    %{
      gtfs_route_type: 3,
      mode: "Bus",
      description: "Used for short- and long-distance bus routes."
    },
    %{
      gtfs_route_type: 4,
      mode: "Ferry",
      description: "Used for short- and long-distance boat service."
    },
    %{
      gtfs_route_type: 5,
      mode: "Cable tram",
      description:
        "Used for street-level rail cars where the cable runs beneath the vehicle, such as cable cars in San Francisco."
    },
    %{
      gtfs_route_type: 6,
      mode: "Aerial lift, suspended cable car",
      description:
        "Cable transport where cabins, cars, gondolas, or open chairs are suspended by one or more cables."
    },
    %{
      gtfs_route_type: 7,
      mode: "Funicular",
      description: "Any rail system designed for steep inclines."
    },
    %{
      gtfs_route_type: 11,
      mode: "Trolleybus",
      description: "Electric buses that draw power from overhead wires using poles."
    },
    %{
      gtfs_route_type: 12,
      mode: "Monorail",
      description: "Railway in which the track consists of a single rail or beam."
    }
  ]

  def all, do: @route_types

  def insert_all do
    now =
      DateTime.utc_now()
      |> DateTime.truncate(:microsecond)

    Enum.map(@route_types, fn route_type ->
      Map.merge(route_type, %{
        inserted_at: now,
        updated_at: now
      })
    end)
    |> TransportModes.insert_all()
  end
end
