defmodule TransitWatch.Repo.Migrations.RenameJoinGtfsAgencyFeedVersions do
  use Ecto.Migration

  def change do
    rename table("gtfs_feed_versions_agencies"), to: table("gtfs_agency_feed_versions")
  end
end
