defmodule TransitWatch.Shapes.Shape do
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

  schema "shapes" do
    field :gtfs_shape_id, :integer
    field :shape_pt_lat, :float
    field :shape_pt_lon, :float
    field :shape_pt_sequence, :integer
    field :shape_dist_traveled, :float
  end

  def changeset(route, attrs) do
    route
    |> cast(attrs, [
      :gtfs_shape_id,
      :shape_pt_lat,
      :shape_pt_lon,
      :shape_pt_sequence,
      :shape_dist_traveled
    ])
    |> validate_required([
      :gtfs_shape_id,
      :shape_pt_lat,
      :shape_pt_lon,
      :shape_pt_sequence
    ])
    |> unique_constraint([:gtfs_shape_id, :shape_pt_sequence])
  end
end
