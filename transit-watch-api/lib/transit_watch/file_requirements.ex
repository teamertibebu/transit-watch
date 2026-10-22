defmodule TransitWatch.FileRequirements do
  @moduledoc """
    Defines the different file requirements for conditional required and conditionally forbidden files.
  """

  # TODO: Need tests
  def verify(extraction_dir, "calendar.txt" = file_name) do
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

  def verify(extraction_dir, "calendar_dates.txt" = file_name) do
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

  def verify(extraction_dir, "stops.txt" = file_name) do
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

  def verify(extraction_dir, "feed_info.txt" = file_name) do
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

  def verify(extraction_dir, "levels.txt" = file_name) do
    pathways_path = Path.join(extraction_dir, "pathways.txt")
    pathways_present? = File.regular?(pathways_path)

    if pathways_present? do
      elevator_present? =
        pathways_path
        |> File.stream!()
        |> CSV.decode!(headers: true)
        |> Enum.any?(&(&1["pathway_mode"] == "5"))

      if elevator_present? do
        {:invalid,
         {file_name,
          "'#{file_name}' is required because 'pathways.txt' contains an elevator (pathway_mode=5), but it was not provided."}}
      else
        :valid
      end
    else
      :valid
    end
  end

  def verify(extraction_dir, file_name)
      when file_name in ["route_networks.txt", "networks.txt"] do
    file_headers =
      extraction_dir
      |> Path.join("routes.txt")
      |> File.open([:read])
      |> then(fn {:ok, file} ->
        IO.read(file, :line)
      end)

    if String.contains?(file_headers, "network_id") do
      {:invalid,
       {file_name, "'#{file_name}' is forbidden since 'network_id' was provided in routes.txt"}}
    else
      :valid
    end
  end
end
