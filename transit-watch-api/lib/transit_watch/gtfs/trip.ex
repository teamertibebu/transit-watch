defmodule TransitWatch.GTFS.Trip do
  @moduledoc """
  Schema definition for Trips.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias TransitWatch.Routes.Route
  alias TransitWatch.Shapes.Shape

  schema "trips" do
    field :gtfs_trip_id, :integer
    field :gtfs_service_id, :integer
    field :trip_headsign, :string
    field :trip_short_name, :string
    field :direction_id, :integer
    field :block_id, :string
    field :wheelchair_accessible, :integer
    field :bikes_allowed, :integer

    belongs_to :route, Route
    belongs_to :shape, Shape
  end

  def changeset(route, attrs) do
    route
    |> cast(attrs, [
      :gtfs_trip_id,
      :gtfs_service_id,
      :trip_headsign,
      :trip_short_name,
      :direction_id,
      :block_id,
      :wheelchair_accessible,
      :bikes_allowed,
      :route_id,
      :shape_id
    ])
    |> validate_required([
      :gtfs_trip_id,
      :gtfs_service_id,
      :route_id
    ])
    |> unique_constraint([:gtfs_trip_id])
  end
end
