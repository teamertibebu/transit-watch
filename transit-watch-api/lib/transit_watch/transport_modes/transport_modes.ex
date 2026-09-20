defmodule TransitWatch.TransportModes.TransportModes do
  @moduledoc """

  """

  alias TransitWatch.Repo
  alias TransitWatch.TransportModes.TransportMode

  def insert_all(attrs), do: Repo.insert_all(TransportMode, attrs)

  def get_by(opts) do
    gtfs_route_type = Keyword.get(opts, :gtfs_route_type)
    IO.inspect(gtfs_route_type, label: "lkajdflkasdjf")

    TransportMode
    |> TransportMode.filter(:gtfs_route_type, gtfs_route_type)
    |> Repo.one()
  end
end
