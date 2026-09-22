defmodule TransitWatch.Repo.Migrations.CreateGtfsFeedVersions do
  use Ecto.Migration

  def change do
    create table("gtfs_feed_versions") do
      add :publisher_name, :string
      add :publisher_url, :string

      add :publisher_feed_version, :string
      add :valid_from, :date
      add :valid_until, :date
      add :gtfs_feed_id, :string

      add :source_sha256, :string, null: false
      add :import_version, :integer, null: false
      add :source_url, :string, null: false
      add :status, :string, null: false, default: "pending"

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:gtfs_feed_versions, [:source_sha256])
    create unique_index(:gtfs_feed_versions, [:import_version])
  end
end
