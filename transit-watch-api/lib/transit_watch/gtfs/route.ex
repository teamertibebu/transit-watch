defmodule TransitWatch.GTFS.Route do
  @moduledoc """
  Schema definition for Routes.

  A route is a group of trips that are displayed to riders as a single service.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias TransitWatch.GTFS.Agency
  alias TransitWatch.GTFS.TransportMode
  alias TransitWatch.GTFS.Trip

  schema "gtfs_routes" do
    field :gtfs_route_id, :integer
    field :route_short_name, :string
    field :route_long_name, :string
    field :route_desc, :string
    field :route_url, :string
    field :route_color, :string
    field :route_text_color, :string

    belongs_to :agency, Agency
    belongs_to :transport_mode, TransportMode

    has_many :trip, Trip

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(route, attrs) do
    route
    |> cast(attrs, [
      :gtfs_route_id,
      :agency_id,
      :transport_mode_id,
      :route_short_name,
      :route_long_name,
      :route_desc,
      :route_url,
      :route_color,
      :route_text_color
    ])
    |> validate_required([:gtfs_route_id, :route_type, :route_type_desc])
    |> unique_constraint(:gtfs_route_id)
    |> unique_constraint(:name)
  end
end
