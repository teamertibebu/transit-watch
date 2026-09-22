defmodule TransitWatch.Repo.Migrations.AddForeignKeyRelationshipToGtfsFeedVersions do
  use Ecto.Migration

  def change do
    alter table("gtfs_routes"),
      do: add(:gtfs_feed_version_id, references("gtfs_feed_versions"))

    alter table("gtfs_shapes"),
      do: add(:gtfs_feed_version_id, references("gtfs_feed_versions"))

    alter table("gtfs_stops"),
      do: add(:gtfs_feed_version_id, references("gtfs_feed_versions"))

    alter table("gtfs_trips"),
      do: add(:gtfs_feed_version_id, references("gtfs_feed_versions"))
  end
end
