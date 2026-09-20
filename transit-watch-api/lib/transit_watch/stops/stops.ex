defmodule TransitWatch.Stops.Stops do
  @moduledoc """
  Context module for interacting with Stops.
  """

  alias TransitWatch.Stops.Stop
  alias TransitWatch.Repo

  def insert(attrs) do
    %Stop{}
    |> Stop.changeset(attrs)
    |> Repo.insert()
  end

  def insert_all(attrs), do: Repo.insert_all(Stop, attrs)

  def list_all, do: Repo.all(Stop)
end
