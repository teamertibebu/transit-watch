defmodule TransitWatch.GTFS.Importers.ShapeImporterV2 do
  @moduledoc """

  """

  alias TransitWatch.GTFS

  ## TODO: Be sure to incorporate feed_version logic

  def import(file_path) do
    file_path
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Enum.reduce({MapSet.new(), []}, fn row, {shape_ids, shape_point_attrs} ->
      shape = %{gtfs_shape_id: Map.get(row, "shape_id")}
      unique_shapes = MapSet.put(shape_ids, shape)

      shape_point_attrs = [to_shape_point_attr(row) | shape_point_attrs]

      {unique_shapes, shape_point_attrs}
    end)
    |> to_shape_point_stream
    |> Stream.chunk_every(5000)
    |> Enum.each(&GTFS.insert_all_shape_points/1)
  end

  defp to_shape_point_attr(row) do
    %{
      lat: String.to_float(row["shape_pt_lat"]),
      long: String.to_float(row["shape_pt_lon"]),
      sequence: String.to_integer(row["shape_pt_sequence"]),
      distance_traveled: String.to_float(row["shape_dist_traveled"]),
      gtfs_shape_id: row["shape_id"]
    }
  end

  defp to_shape_point_stream({unique_shapes, shape_point_attrs}) do
    {_, shape_maps} =
      unique_shapes
      |> MapSet.to_list()
      |> GTFS.insert_all_shapes(returning: [:id, :gtfs_shape_id])

    lookup_map = create_shapes_lookup(shape_maps)

    Stream.map(shape_point_attrs, fn shape_point ->
      shape_id = Map.get(lookup_map, shape_point.gtfs_shape_id)

      shape_point
      |> Map.delete(:gtfs_shape_id)
      |> Map.put(:shape_id, shape_id)
    end)
  end

  defp create_shapes_lookup(shape_maps) do
    Enum.reduce(shape_maps, %{}, fn shape, lookup_map ->
      Map.put(lookup_map, shape.gtfs_shape_id, shape.id)
    end)
  end
end
