defmodule TransitWatch.Shapes.ShapeParser do
  @moduledoc """
  A module for parsing Shape information from GTFS feeds.
  Rules for mapping vehicle travel paths, sometimes referred to as route alignments.
  """

  alias TransitWatch.Shapes.Shapes

  def parse(file_path) do
    file_path
    |> File.stream!()
    |> CSV.decode(headers: true)
    |> Stream.map(&to_shape_attrs/1)
    |> Stream.chunk_every(1_000)
    |> Enum.each(&Shapes.insert_all/1)
  end

  defp to_shape_attrs({:ok, row}) do
    %{
      gtfs_shape_id: String.to_integer(row["shape_id"]),
      shape_pt_lat: String.to_float(row["shape_pt_lat"]),
      shape_pt_lon: String.to_float(row["shape_pt_lon"]),
      shape_pt_sequence: String.to_integer(row["shape_pt_sequence"]),
      shape_dist_traveled: String.to_float(row["shape_dist_traveled"])
    }
  end
end
