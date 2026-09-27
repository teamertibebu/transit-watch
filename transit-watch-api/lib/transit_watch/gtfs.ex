defmodule TransitWatch.GTFS do
  @moduledoc """
  CRUD functions for GTFS feed tables.
  """

  import Ecto.Query

  alias TransitWatch.GTFS.Agency
  alias TransitWatch.GTFS.FeedVersion
  alias TransitWatch.GTFS.LocationType
  alias TransitWatch.GTFS.Route
  alias TransitWatch.GTFS.ShapePoint
  alias TransitWatch.GTFS.Stop
  alias TransitWatch.GTFS.TransportMode
  alias TransitWatch.Repo

  ## Feed Versions

  def get_active_feed_version_for_agency(agency_id) do
    FeedVersion
    |> join(:inner, [fv], a in assoc(fv, :agencies))
    |> where([fv, a], a.id == ^agency_id)
    |> where([fv], fv.status == :active)
    |> Repo.one()
  end

  ## Agencies

  def get_agency_by(opts \\ []) do
    id = Keyword.get(opts, :id)

    Agency
    |> Agency.filter(:id, id)
    |> Repo.one()
  end

  def insert_all_agencies(attrs, opts \\ []), do: Repo.insert_all(Agency, attrs, opts)

  def list_agencies, do: Repo.all(Agency)

  ## Routes

  def insert_all_routes(attrs, opts \\ []), do: Repo.insert_all(Route, attrs, opts)

  ## Transport Modes

  def list_transport_modes, do: Repo.all(TransportMode)

  ## Stops

  def insert_all_stops(attrs, opts \\ []), do: Repo.insert_all(Stop, attrs, opts)

  ## Shapes

  def insert_all_shapes(attrs, opts \\ []), do: Repo.insert_all("gtfs_shapes", attrs, opts)

  ## Shape Points

  def insert_all_shape_points(attrs, opts \\ []), do: Repo.insert_all(ShapePoint, attrs, opts)

  ## Location Types

  def list_location_types, do: Repo.all(LocationType)
end
