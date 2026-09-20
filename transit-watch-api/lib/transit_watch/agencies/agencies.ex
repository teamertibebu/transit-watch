defmodule TransitWatch.Agencies.Agencies do
  @moduledoc """
  A module for managing agencies.
  """

  alias TransitWatch.Agencies.Agency
  alias TransitWatch.Repo

  def insert(attrs) do
    %Agency{}
    |> Agency.changeset(attrs)
    |> Repo.insert()
  end

  def insert_all(attrs), do: Repo.insert_all(Agency, attrs)

  def get_by(opts) do
    gtfs_agency_id = Keyword.get(opts, :gtfs_agency_id)

    Agency
    |> Agency.filter(:gtfs_agency_id, gtfs_agency_id)
    |> Repo.one()
  end

  def list_all, do: Repo.all(Agency)
end
