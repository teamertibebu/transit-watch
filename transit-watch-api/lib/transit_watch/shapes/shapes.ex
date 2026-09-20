defmodule TransitWatch.Shapes.Shapes do
  @moduledoc """
  Context module for interacting with Shapes.
  """

  alias TransitWatch.Shapes.Shape
  alias TransitWatch.Repo

  def insert(attrs) do
    %Shape{}
    |> Shape.changeset(attrs)
    |> Repo.insert()
  end

  def insert_all(attrs), do: Repo.insert_all(Shape, attrs)

  def list_all, do: Repo.all(Shape)
end
