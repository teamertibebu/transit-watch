defmodule TransitWatch.GTFS do
  @moduledoc """
  CRUD functions for GTFS feed tables.
  """

  import Ecto.Query

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

  ## TODO: All but 'levels.txt' have finalized implementations. 'levels.txt' has a function definition, serving solely as a bypass.
  @conditionally_required_gtfs_files ~w(stops.txt calendar.txt calendar_dates.txt levels.txt feed_info.txt)

  ## TODO: Implementation for conditionally forbidden GTFS files is still needed.
  # @conditionally_forbidden_gtfs_files ~w(networks.txt route_networks.txt)

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
      IO.inspect(file_manifest, label: "THE FILE MANIFEST")

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

    {conditionally_required_files_validity, cond_req_error_reasons} =
      verify_conditionally_required_files(extraction_dir)

    %{
      "required_files_present?" => required_files_present?,
      "missing_required_files" => missing_required_files,
      "conditionally_required_files_validity" => conditionally_required_files_validity,
      "cond_req_error_reasons" => cond_req_error_reasons
    }
  end

  defp build_file_manifest(extraction_dir) do
    # verify_conditionally_required_files(extraction_dir)
    %{
      "required_files_present?" => required_files_present?,
      "missing_required_files" => missing_required_files,
      "conditionally_required_files_validity" => conditionally_required_files_validity,
      "cond_req_error_reasons" => cond_req_error_reasons
    } = verify_files(extraction_dir)

    cond do
      not required_files_present? ->
        {:error, {:missing_required_gtfs_files, missing_required_files}}

      conditionally_required_files_validity == :invalid ->
        ## Iterate through <cond_req_error_reasons> and join for a clear error message
        ## [{file_name, reason}, {file_name, reason}, ...]
        {:error,
         Enum.reduce(cond_req_error_reasons, "Error(s) ->", fn error_tuple, acc_str ->
           file = elem(error_tuple, 0)
           reason = elem(error_tuple, 1)

           "#{acc_str} [FILE_AFFECTED: #{file}, MESSAGE: #{reason}]"
         end)}

      required_files_present? == true && conditionally_required_files_validity == :valid ->
        manifest_map = build_manifest_map(extraction_dir)

        {:ok, manifest_map}

        # {:ok,
        #  %{
        #    # Required:

        #    agency: Path.join(extraction_dir, "agency.txt"),
        #    routes: Path.join(extraction_dir, "routes.txt"),
        #    trips: Path.join(extraction_dir, "trips.txt"),
        #    stop_times: Path.join(extraction_dir, "stop_times.txt"),

        #    ## Optional:
        #    fare_attributes: optional_file_path(extraction_dir, "fare_attributes.txt"),
        #    fare_rules: optional_file_path(extraction_dir, "fare_rules.txt"),
        #    timeframes: optional_file_path(extraction_dir, "timeframes.txt"),
        #    rider_categories: optional_file_path(extraction_dir, "rider_categories.txt"),
        #    fare_media: optional_file_path(extraction_dir, "fare_media.txt"),
        #    fare_products: optional_file_path(extraction_dir, "fare_products.txt"),
        #    fare_leg_rules: optional_file_path(extraction_dir, "fare_leg_rules.txt"),
        #    fare_leg_join_rules: optional_file_path(extraction_dir, "fare_leg_join_rules.txt"),
        #    fare_transfer_rules: optional_file_path(extraction_dir, "fare_transfer_rules.txt"),
        #    areas: optional_file_path(extraction_dir, "areas.txt"),
        #    stop_areas: optional_file_path(extraction_dir, "stop_areas.txt"),
        #    shapes: optional_file_path(extraction_dir, "shapes.txt"),
        #    frequencies: optional_file_path(extraction_dir, "frequencies.txt"),
        #    transfers: optional_file_path(extraction_dir, "transfers.txt"),
        #    pathways: optional_file_path(extraction_dir, "pathways.txt"),
        #    location_groups: optional_file_path(extraction_dir, "location_groups.txt"),
        #    location_group_stops: optional_file_path(extraction_dir, "location_group_stops.txt"),
        #    booking_rules: optional_file_path(extraction_dir, "booking_rules.txt"),
        #    translations: optional_file_path(extraction_dir, "translations.txt"),
        #    attributions: optional_file_path(extraction_dir, "attributions.txt"),

        #    ## Conditionally Required - will require additional logic to verify if/if not required based off of specificfeed.
        #    stops: optional_file_path(extraction_dir, "stops.txt"),
        #    calendar: optional_file_path(extraction_dir, "calendar.txt"),
        #    calendar_dates: optional_file_path(extraction_dir, "calendar_dates.txt"),
        #    levels: optional_file_path(extraction_dir, "levels.txt"),
        #    feed_info: optional_file_path(extraction_dir, "feed_info.txt")
        #    ###############

        #    ## Conditionally Forbidden - will require additional logic to verify whether forbidden or not.
        #    # networks: Path.join(extraction_dir, "networks.txt"),
        #    # route_networks: Path.join(extraction_dir, "route_networks.txt"),
        #    ###############
        #  }}
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

  defp verify_conditionally_required_files(extraction_dir) do
    ## Each of @conditionally_required_gtfs_files will have their own requirement rules.
    ## Need to verify whether each is required or not
    ## If requirements are not met, error should be returned, processing should halt.
    ## If all required files are present, proceed.
    ## optional_file_path/2 can be used in the manifest map to set the file path or mark nil.

    Enum.reduce(@conditionally_required_gtfs_files, {:valid, []}, fn file_name, acc ->
      case verify_file_requirement(extraction_dir, file_name) do
        :valid ->
          acc

        {:invalid, {file_name, reason}} ->
          invalid_reasons_list = elem(acc, 1)

          updated_invalid_reasons_list = [{file_name, reason} | invalid_reasons_list]

          {:invalid, updated_invalid_reasons_list}
      end
    end)
  end

  defp verify_file_requirement(extraction_dir, "calendar.txt" = file_name) do
    calendar_present? =
      extraction_dir
      |> Path.join("calendar.txt.")
      |> File.regular?()

    calendar_dates_present? =
      extraction_dir
      |> Path.join("calendar_dates.txt")
      |> File.regular?()

    cond do
      calendar_dates_present? ->
        :valid

      calendar_dates_present? == false and calendar_present? == true ->
        :valid

      calendar_dates_present? == false and calendar_present? == false ->
        {:invalid,
         {file_name,
          "#{file_name} is required if 'calendar_dates.txt' is omitted. 'calendar_dates.txt' has been omitted."}}
    end
  end

  defp verify_file_requirement(extraction_dir, "calendar_dates.txt" = file_name) do
    calendar_present? =
      extraction_dir
      |> Path.join("calendar.txt.")
      |> File.regular?()

    calendar_dates_present? =
      extraction_dir
      |> Path.join("calendar_dates.txt")
      |> File.regular?()

    cond do
      calendar_present? == true ->
        :valid

      calendar_present? == false and calendar_dates_present? == true ->
        :valid

      calendar_present? == false and calendar_dates_present? == false ->
        {:invalid,
         {file_name,
          "#{file_name} is required if 'calendar.txt' is omitted. 'calendar.txt' has been omitted."}}
    end
  end

  defp verify_file_requirement(extraction_dir, "stops.txt" = file_name) do
    locations_geojson_present? =
      extraction_dir
      |> Path.join("locations.geojson.")
      |> File.regular?()

    stops_present? =
      extraction_dir
      |> Path.join("stops.txt")
      |> File.regular?()

    cond do
      ## If locations.geojson is present, stops.txt in optional, so :valid is returned whether or not stops.txt is present.
      locations_geojson_present? == true ->
        :valid

      ## If locations.geojson is not provided, :valid will be returned if stops.txt is present.
      locations_geojson_present? == false and stops_present? == true ->
        :valid

      ## If locations.geojson is not provided, stops.txt is required, and if not provided, defines the only :invalid pathway.
      locations_geojson_present? == false and stops_present? == false ->
        {:invalid,
         {file_name,
          "'locations.geojson' was not provided, therefore, stops.txt is required but was not provided."}}
    end
  end

  defp verify_file_requirement(extraction_dir, "feed_info.txt" = file_name) do
    ## The GTFS spec notes that 'feed_info.txt' is required when 'translations.txt' is present.
    translations_present? =
      extraction_dir
      |> Path.join("translations.txt")
      |> File.regular?()

    feed_info_present? =
      extraction_dir
      |> Path.join("feed_info.txt")
      |> File.regular?()

    cond do
      translations_present? && not feed_info_present? ->
        {:invalid,
         {file_name,
          "'#{file_name}' was not provided but is required when 'translations.txt' is present."}}

      true ->
        :valid
    end
  end

  ## TODO: Will require that I check for existence of pathways.txt and if pathways are described with elevators (pathway_mode=5). The following is provided from the GTFS docs: Required when describing pathways with elevators (pathway_mode=5). Optional otherwise.
  ## Set to :valid as a bypass until function is implemented.
  defp verify_file_requirement(_extraction_dir, "levels.txt"), do: :valid

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
