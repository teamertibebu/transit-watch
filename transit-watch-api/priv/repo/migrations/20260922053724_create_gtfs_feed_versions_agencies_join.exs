defmodule TransitWatch.Repo.Migrations.CreateGtfsFeedVersionsAgencies do
  use Ecto.Migration

  def change do
    create table("gtfs_feed_versions_agencies", primary_key: false) do
      add :gtfs_feed_version_id,
          references(:gtfs_feed_versions, on_delete: :delete_all),
          null: false

      add :gtfs_agency_id,
          references(:gtfs_agencies, on_delete: :delete_all),
          null: false
    end

    create unique_index(
             :gtfs_feed_versions_agencies,
             [:gtfs_feed_version_id, :gtfs_agency_id]
           )
  end
end
