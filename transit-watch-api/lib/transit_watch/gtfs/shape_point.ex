defmodule TransitWatch.GTFS.ShapePoint do
  @moduledoc """
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias TransitWatch.GTFS.Shape

  schema "shape_points" do
    field :lat, :float
    field :long, :float
    field :sequence, :integer
    field :distance_traveled, :float

    belongs_to :shape, Shape
  end

  def changeset(route, attrs) do
    route
    |> cast(attrs, [:lat, :long, :sequence, :distance_traveled])
    |> validate_required([:lat, :long, :sequence])
    |> unique_constraint([:shape_id, :sequence])
  end
end
