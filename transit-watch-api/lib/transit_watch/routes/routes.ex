defmodule TransitWatch.Routes.Routes do
  @moduledoc """
  A module for managing transit routes.
  """

  alias TransitWatch.Routes.Route
  alias TransitWatch.Repo

  def insert(attrs) do
    %Route{}
    |> Route.changeset(attrs)
    |> Repo.insert()
  end

  def insert_all(attrs), do: Repo.insert_all(Route, attrs)
end
