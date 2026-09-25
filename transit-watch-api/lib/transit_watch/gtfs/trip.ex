defmodule TransitWatch.GTFS.Trip do
  @moduledoc """
  Schema definition for Trips.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias TransitWatch.GTFS.FeedVersion
  alias TransitWatch.GTFS.Route
  alias TransitWatch.GTFS.Shape

  schema "gtfs_trips" do
    field :gtfs_trip_id, :string
    field :gtfs_service_id, :string
    field :headsign, :string
    field :short_name, :string
    field :direction_of_travel, Ecto.Enum, values: [outbound: 0, inbound: 1]
    field :block_code, :string

    field :wheelchair_accessible, Ecto.Enum,
      values: [unknown: 0, accessible: 1, not_accessible: 2]

    field :bikes_allowed, Ecto.Enum, values: [unknown: 0, allowed: 1, not_allowed: 2]

    belongs_to :gtfs_feed_version, FeedVersion
    belongs_to :route, Route
    belongs_to :shape, Shape
  end

  def changeset(trip, attrs) do
    trip
    |> cast(attrs, [
      :gtfs_trip_id,
      :gtfs_service_id,
      :headsign,
      :short_name,
      :direction_of_travel,
      :block_code,
      :wheelchair_accessible,
      :bikes_allowed,
      :route_id,
      :shape_id,
      :gtfs_feed_version_id
    ])
    |> validate_required([
      :gtfs_trip_id,
      :gtfs_service_id,
      :route_id,
      :gtfs_feed_version_id
    ])
    |> unique_constraint([:gtfs_trip_id, :gtfs_feed_version_id],
      name: "trip_id_per_feed_version_index"
    )
    |> foreign_key_constraint(:gtfs_feed_version_id)
    |> foreign_key_constraint(:route_id)
    |> foreign_key_constraint(:shape_id)
  end
end
