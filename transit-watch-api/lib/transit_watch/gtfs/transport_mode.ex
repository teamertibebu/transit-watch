defmodule TransitWatch.GTFS.TransportMode do
  use Ecto.Schema

  import Ecto.Query

  alias TransitWatch.Routes.Route

  schema "transport_modes" do
    field :gtfs_route_type, :integer
    field :mode, :string
    field :description, :string

    has_many :routes, Route

    timestamps(type: :utc_datetime_usec)
  end

  def filter(query, :gtfs_route_type, nil), do: query

  def filter(query, :gtfs_route_type, gtfs_route_type),
    do: where(query, gtfs_route_type: ^gtfs_route_type)
end
