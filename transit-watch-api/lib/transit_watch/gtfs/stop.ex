defmodule TransitWatch.GTFS.Stop do
  @moduledoc """
  Schema definition for Stops.

  Stops where vehicles pick up or drop off riders.
  Also defines stations and station entrances.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias TransitWatch.GTFS.LocationType

  schema "gtfs_stops" do
    field :gtfs_stop_id, :integer
    field :code, :string
    field :name, :string
    field :desc, :string
    field :lat, :float
    field :long, :float
    field :url, :string
    field :parent_station, :integer
    field :wheelchair_boarding, :integer

    belongs_to :location_type, LocationType

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(agency, attrs) do
    agency
    |> cast(attrs, [
      :gtfs_stop_id,
      :code,
      :name,
      :desc,
      :lat,
      :long,
      :stop_url,
      :parent_station,
      :wheelchair_boarding,
      :location_type_id
    ])
    |> validate_required([:gtfs_stop_id])
    |> unique_constraint(:gtfs_agency_id)
    |> unique_constraint(:name)
  end
end
