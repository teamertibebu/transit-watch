defmodule TransitWatch.GTFS.Shape do
  @moduledoc """
  Schema definition for Shapes.

  Shapes describe the path that a vehicle travels along a route alignment,
  and are defined in the file shapes.txt. Shapes are associated with Trips,
  and consist of a sequence of points through which the vehicle passes in order.
  Shapes do not need to intercept the location of Stops exactly, but all Stops
  on a trip should lie within a small distance of the shape for that trip,
  i.e. close to straight line segments connecting the shape points.
  The shapes.txt file should be included for all route-based services
  (not for zone-based demand-responsive services).
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias TransitWatch.GTFS.FeedVersion
  alias TransitWatch.GTFS.ShapePoint
  alias TransitWatch.GTFS.Trip

  schema "gtfs_shapes" do
    field :gtfs_shape_id, :integer

    belongs_to :gtfs_feed_version, FeedVersion

    has_many :trips, Trip
    has_many :shape_points, ShapePoint
  end

  def changeset(route, attrs) do
    route
    |> cast(attrs, [:gtfs_shape_id])
    |> validate_required([:gtfs_shape_id])
    |> unique_constraint([:gtfs_shape_id])
  end
end
