defmodule TransitWatch.LocationTypes.LocationTypes do
  @moduledoc """
  A module for managing LocationTypes.
  """

  alias TransitWatch.LocationTypes.LocationType
  alias TransitWatch.Repo

  def insert(attrs) do
    %LocationType{}
    |> LocationType.changeset(attrs)
    |> Repo.insert()
  end

  def insert_all(attrs), do: Repo.insert_all(LocationType, attrs)

  def list_all, do: Repo.all(LocationType)
end
