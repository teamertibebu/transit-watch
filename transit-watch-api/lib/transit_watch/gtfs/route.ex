defmodule TransitWatch.GTFS.Route do
  @moduledoc """
  Schema definition for Routes.

  A route is a group of trips that are displayed to riders as a single service.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias TransitWatch.GTFS.Agency
  alias TransitWatch.GTFS.FeedVersion
  alias TransitWatch.GTFS.TransportMode
  alias TransitWatch.GTFS.Trip

  schema "gtfs_routes" do
    field :gtfs_route_id, :integer
    field :short_name, :string
    field :long_name, :string
    field :description, :string
    field :url, :string
    field :designated_color, :string
    field :designated_text_color, :string

    belongs_to :agency, Agency
    belongs_to :gtfs_feed_version, FeedVersion
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
      :gtfs_feed_version_id,
      :short_name,
      :long_name,
      :description,
      :url,
      :designated_color,
      :designated_text_color
    ])
    |> validate_required([:gtfs_route_id])
    |> unique_constraint(:gtfs_route_id)
  end
end
