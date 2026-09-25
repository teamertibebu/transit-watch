defmodule TransitWatch.Repo.Migrations.FixGtfsTripsFieldTypes do
  use Ecto.Migration

  def up do
    alter table("gtfs_trips") do
      modify :gtfs_trip_id, :string
      modify :gtfs_service_id, :string
    end

    rename table("gtfs_trips"), :trip_headsign, to: :headsign
    rename table("gtfs_trips"), :trip_short_name, to: :short_name
    rename table("gtfs_trips"), :direction_id, to: :direction_of_travel
    rename table("gtfs_trips"), :block_id, to: :block_code

    alter table("gtfs_trips") do
      modify :direction_of_travel, :string
      modify :gtfs_feed_version_id,
             references(:gtfs_feed_versions),
             null: false,
             from: references(:gtfs_feed_versions)
    end

    drop unique_index("gtfs_trips", [:gtfs_trip_id], [name: "trips_gtfs_trip_id_index"])
    create unique_index("gtfs_trips", [:gtfs_trip_id, :gtfs_feed_version_id], [name: "trip_id_per_feed_version_index"])
  end

  def down do
    alter table("gtfs_trips") do
      remove :gtfs_trip_id
      remove :gtfs_service_id
      add :gtfs_trip_id, :integer
      add :gtfs_service_id, :integer
    end

    rename table("gtfs_trips"), :headsign, to: :trip_headsign
    rename table("gtfs_trips"), :short_name, to: :trip_short_name
    rename table("gtfs_trips"), :direction_of_travel, to: :direction_id
    rename table("gtfs_trips"), :block_code, to: :block_id

    alter table("gtfs_trips") do
      remove :direction_id
      add :direction_id, :integer
      modify :gtfs_feed_version_id,
             references(:gtfs_feed_versions),
             null: true,
             from: references(:gtfs_feed_versions)
    end

    create unique_index("gtfs_trips", [:gtfs_trip_id], [name: "trips_gtfs_trip_id_index"])
    drop_if_exists unique_index("gtfs_trips", [:gtfs_trip_id, :gtfs_feed_version_id], [name: "trip_id_per_feed_version_index"])
  end
end
