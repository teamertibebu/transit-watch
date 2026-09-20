defmodule TransitWatch.Agencies.Agency do
  @moduledoc """
  Schema definition for Agencies.

  Transit agencies with service represented in the dataset.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias TransitWatch.Routes.Route

  schema "agencies" do
    field :gtfs_agency_id, :string
    field :name, :string
    field :main_url, :string
    field :fare_url, :string
    field :timezone, :string
    field :phone, :string

    has_many :routes, Route

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(agency, attrs) do
    agency
    |> cast(attrs, [:gtfs_agency_id, :name, :main_url, :fare_url, :timezone, :phone])
    |> validate_required([:gtfs_agency_id, :name])
    |> unique_constraint(:gtfs_agency_id)
    |> unique_constraint(:name)
  end

  def filter(query, :gtfs_agency_id, nil), do: query

  def filter(query, :gtfs_agency_id, gtfs_agency_id) do
    where(query, gtfs_agency_id: ^gtfs_agency_id)
  end
end
