defmodule TransitWatch.GTFS.LocationType do
  @moduledoc """
  Schema definition for Location Types. Can be one of: Stop/Platform, Station, Entrance/Exit, Generic Node, or Boarding Area
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias TransitWatch.GTFS.Stop

  schema "location_types" do
    field :gtfs_locaton_type, :integer
    field :name, :string
    field :desc, :string

    has_many :stops, Stop
  end

  def changeset(location_type, attrs) do
    location_type
    |> cast(attrs, [:gtfs_locaton_type, :name, :desc])
    |> validate_required([:gtfs_locaton_type])
    |> unique_constraint(:gtfs_locaton_type)
  end
end
