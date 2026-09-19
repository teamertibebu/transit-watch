defmodule TransitWatch.Agencies.Agency do
  @moduledoc """
  A module for working with transit agencies.
  """

  use Ecto.Schema

  import Ecto.Changeset

  schema "agencies" do
    field :short_name, :string
    field :long_name, :string
    field :main_url, :string
    field :fare_url, :string
    field :timezone, :string
    field :phone, :string

    timestamps()
  end

  def changeset(agency, attrs) do
    agency
    |> cast(attrs, [:short_name, :long_name, :main_url, :fare_url, :timezone, :phone])
    |> validate_required([:short_name, :long_name])
    |> unique_constraint(:short_name)
    |> unique_constraint(:long_name)
  end
end
