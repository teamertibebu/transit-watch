defmodule TransitWatch.GTFS do
  @moduledoc """
  CRUD functions for GTFS feed tables.
  """

  # TODO: Need tests
  import Ecto.Query

  alias TransitWatch.FileRequirements
  alias TransitWatch.GTFS.Agency
  alias TransitWatch.GTFS.FeedVersion
  alias TransitWatch.GTFS.LocationType
  alias TransitWatch.GTFS.Route
  alias TransitWatch.GTFS.ShapePoint
  alias TransitWatch.GTFS.Stop
  alias TransitWatch.GTFS.TransportMode
  alias TransitWatch.Repo

  @required_gtfs_files ~w(agency.txt routes.txt trips.txt stop_times.txt)

  @optional_gtfs_files ~w(
    fare_attributes.txt
    fare_rules.txt
    timeframes.txt
    rider_categories.txt
    fare_media.txt
    fare_products.txt
    fare_leg_rules.txt
    fare_leg_join_rules.txt
    fare_transfer_rules.txt
    areas.txt
    stop_areas.txt
    shapes.txt
    frequencies.txt
    transfers.txt
    pathways.txt
    location_groups.txt
    location_group_stops.txt
    locations.geojson
    booking_rules.txt
    translations.txt
    attributions.txt
    )

  @conditionally_required_gtfs_files ~w(stops.txt calendar.txt calendar_dates.txt levels.txt feed_info.txt)

  @conditionally_forbidden_gtfs_files ~w(networks.txt route_networks.txt)

  @all_conditional_gtfs_files @conditionally_forbidden_gtfs_files ++
                                @conditionally_required_gtfs_files

  @all_gtfs_files @required_gtfs_files ++
                    @optional_gtfs_files ++ @conditionally_required_gtfs_files

  def start_import(archive_path) do
    extraction_dir = Path.join([System.tmp_dir!(), "gtfs_imports", Ecto.UUID.generate()])

    with true <- File.regular?(archive_path),
         :ok <- File.mkdir_p(extraction_dir),
         {:ok, _extracted_files} <-
           :zip.extract(
             String.to_charlist(archive_path),
             cwd: String.to_charlist(extraction_dir)
           ),
         {:ok, file_manifest} <- build_file_manifest(extraction_dir) do
      {:ok,
       %{
         archive_path: archive_path,
         extraction_dir: extraction_dir,
         file_manifest: file_manifest
       }}
    else
      {:error, {:missing_required_gtfs_files, missing_required_files}} ->
        File.rm_rf(extraction_dir)
        {:error, "Mssing required files: #{Enum.join(missing_required_files, ",")}"}

      false ->
        {:error, :archive_not_found}

      {:error, reason} ->
        File.rm_rf(extraction_dir)
        {:error, reason}
    end
  end

  defp verify_files(extraction_dir) do
    {required_files_present?, missing_required_files} = verify_required_files(extraction_dir)

    {conditional_files_validity, conditional_error_reasons} =
      verify_conditional_files(extraction_dir)

    %{
      "required_files_present?" => required_files_present?,
      "missing_required_files" => missing_required_files,
      "conditional_files_validity" => conditional_files_validity,
      "conditional_error_reasons" => conditional_error_reasons
    }
  end

  defp build_file_manifest(extraction_dir) do
    %{
      "required_files_present?" => required_files_present?,
      "missing_required_files" => missing_required_files,
      "conditional_files_validity" => conditional_files_validity,
      "conditional_error_reasons" => conditional_error_reasons
    } = verify_files(extraction_dir)

    cond do
      not required_files_present? ->
        {:error, {:missing_required_gtfs_files, missing_required_files}}

      conditional_files_validity == :invalid ->
        {:error,
         Enum.reduce(conditional_error_reasons, "Error(s) ->", fn error_tuple, acc_str ->
           file = elem(error_tuple, 0)
           reason = elem(error_tuple, 1)

           "#{acc_str} [FILE_AFFECTED: #{file}, MESSAGE: #{reason}]"
         end)}

      required_files_present? == true && conditional_files_validity == :valid ->
        manifest_map = build_manifest_map(extraction_dir)

        {:ok, manifest_map}
    end
  end

  defp build_manifest_map(extraction_dir) do
    Enum.reduce(@all_gtfs_files, %{}, fn file_name_with_ext, acc_map ->
      [file_name, _file_ext] = String.split(file_name_with_ext, ".")

      if Enum.member?(@required_gtfs_files, file_name_with_ext) do
        file_path = Path.join(extraction_dir, file_name_with_ext)

        Map.put(acc_map, file_name, file_path)
      else
        file_path_or_nil = optional_file_path(extraction_dir, file_name_with_ext)

        Map.put(acc_map, file_name, file_path_or_nil)
      end
    end)
  end

  defp verify_conditional_files(extraction_dir) do
    Enum.reduce(@all_conditional_gtfs_files, {:valid, []}, fn file_name, acc ->
      case FileRequirements.verify(extraction_dir, file_name) do
        :valid ->
          acc

        {:invalid, {file_name, reason}} ->
          invalid_reasons_list = elem(acc, 1)

          updated_invalid_reasons_list = [{file_name, reason} | invalid_reasons_list]

          {:invalid, updated_invalid_reasons_list}
      end
    end)
  end

  defp optional_file_path(extraction_dir, filename) do
    path = Path.join(extraction_dir, filename)

    if File.regular?(path), do: path, else: nil
  end

  defp verify_required_files(extraction_dir) do
    missing_required_files =
      Enum.reject(@required_gtfs_files, &File.regular?(Path.join(extraction_dir, &1)))

    required_files_present? = missing_required_files == []

    {required_files_present?, missing_required_files}
  end

  ## Feed Versions

  def get_active_feed_version_for_agency(agency_id) do
    FeedVersion
    |> join(:inner, [fv], a in assoc(fv, :agencies))
    |> where([fv, a], a.id == ^agency_id)
    |> where([fv], fv.status == :active)
    |> Repo.one()
  end

  ## Agencies

  def get_agency_by(opts \\ []) do
    id = Keyword.get(opts, :id)

    Agency
    |> Agency.filter(:id, id)
    |> Repo.one()
  end

  def insert_all_agencies(attrs, opts \\ []), do: Repo.insert_all(Agency, attrs, opts)

  def list_agencies, do: Repo.all(Agency)

  ## Routes

  def insert_all_routes(attrs, opts \\ []), do: Repo.insert_all(Route, attrs, opts)

  ## Transport Modes

  def list_transport_modes, do: Repo.all(TransportMode)

  ## Stops

  def insert_all_stops(attrs, opts \\ []), do: Repo.insert_all(Stop, attrs, opts)

  ## Shapes

  def insert_all_shapes(attrs, opts \\ []), do: Repo.insert_all("gtfs_shapes", attrs, opts)

  ## Shape Points

  def insert_all_shape_points(attrs, opts \\ []), do: Repo.insert_all(ShapePoint, attrs, opts)

  ## Location Types

  def list_location_types, do: Repo.all(LocationType)
end
