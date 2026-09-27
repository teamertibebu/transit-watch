defmodule TransitWatch.GTFS.Importers.ShapeImporterV2 do
  @moduledoc false

  alias Ecto.MultipleResultsError
  alias TransitWatch.GTFS
  alias TransitWatch.GTFS.Agency
  alias TransitWatch.GTFS.FeedVersion

  def import(file_path, %Agency{id: agency_id, gtfs_agency_id: gtfs_agency_id}) do
    try do
      case GTFS.get_active_feed_version_for_agency(agency_id) do
        nil ->
          {:error,
           "Agency: #{gtfs_agency_id} has no current feed version. Fix before proceeding."}

        %FeedVersion{id: feed_version_id} ->
          file_path
          |> File.stream!()
          |> CSV.decode!(headers: true)
          |> Enum.reduce({MapSet.new(), []}, fn row, {shape_ids, shape_point_attrs} ->
            shape = %{
              gtfs_shape_id: Map.get(row, "shape_id"),
              gtfs_feed_version_id: feed_version_id
            }

            unique_shapes = MapSet.put(shape_ids, shape)

            shape_point_attrs = [to_shape_point_attr(row) | shape_point_attrs]

            {unique_shapes, shape_point_attrs}
          end)
          |> to_shape_point_stream
          |> Stream.chunk_every(5000)
          |> Enum.each(&GTFS.insert_all_shape_points/1)
      end
    rescue
      MultipleResultsError ->
        {:error,
         "Agency: #{gtfs_agency_id} has more than one active feed version. Fix before proceeding."}
    end
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
