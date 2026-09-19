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

  def insert_all(attrs) do
    Repo.insert_all(Agency, attrs)
  end
end
