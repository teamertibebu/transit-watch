defmodule TransitWatch.ShapePoints.ShapePoints do
  @moduledoc """
  Context module for interacting with ShapePoint.
  """

  alias TransitWatch.Repo
  alias TransitWatch.ShapePoints.ShapePoint

  def insert_all(attrs), do: Repo.insert_all(ShapePoint, attrs)
  def insert_all(attrs, opts), do: Repo.insert_all(ShapePoint, attrs, opts)

  def list_all, do: Repo.all(ShapePoint)
end
