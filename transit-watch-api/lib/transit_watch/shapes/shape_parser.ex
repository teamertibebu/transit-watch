defmodule TransitWatch.Shapes.ShapeParser do
  @moduledoc """
  A module for parsing Shape information from GTFS feeds.
  Rules for mapping vehicle travel paths, sometimes referred to as route alignments.
  """

  alias TransitWatch.ShapePoints.ShapePoints
  alias TransitWatch.Shapes.Shapes

  ## TODO: Entire module need to be optimization and cleaned up.

  def import(file_path) do
    file_path
    |> parse()
    |> then(fn {shape_ids, point_attrs} ->
      shapes_list = create_shapes(shape_ids)
      create_shape_points(point_attrs, shapes_list)
    end)
  end

  defp create_shapes(shape_ids) do
    shape_attrs =
      Enum.map(shape_ids, fn id ->
        %{gtfs_shape_id: String.to_integer(id)}
      end)

    {_, shapes_list} = Shapes.insert_all(shape_attrs, returning: [:id, :gtfs_shape_id])

    shapes_list
  end

  defp create_shape_points(point_attrs, shapes_list) do
    Enum.map(point_attrs, fn %{gtfs_shape_id: gtfs_shape_id} = point_attr ->
      shape =
        Enum.find(shapes_list, fn shape ->
          shape.gtfs_shape_id == String.to_integer(gtfs_shape_id)
        end)

      point_attr
      |> Map.put(:shape_id, shape.id)
      |> Map.delete(:gtfs_shape_id)
    end)
    |> Enum.chunk_every(1_000)
    |> Enum.each(fn shape_point_batch ->
      ShapePoints.insert_all(shape_point_batch)
    end)
  end

  def parse(file_path) do
    file_path
    |> File.stream!()
    |> CSV.decode(headers: true)
    |> Enum.reduce({MapSet.new(), []}, fn {:ok, row}, {shape_ids, points} ->
      shape_id = row["shape_id"]

      {
        MapSet.put(shape_ids, shape_id),
        [to_shape_point_attrs(row) | points]
      }
    end)
  end

  defp to_shape_point_attrs(row) do
    %{
      lat: String.to_float(row["shape_pt_lat"]),
      long: String.to_float(row["shape_pt_lon"]),
      sequence: String.to_integer(row["shape_pt_sequence"]),
      distance_traveled: String.to_float(row["shape_dist_traveled"]),
      gtfs_shape_id: row["shape_id"]
    }
  end
end
