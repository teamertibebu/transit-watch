defmodule TransitWatch.GTFS.FeedVersion do
  use Ecto.Schema

  import Ecto.Changeset

  schema "gtfs_feed_versions" do
    field :publisher_name, :string
    field :publisher_url, :string
    field :publisher_feed_version, :string
    field :valid_from, :date
    field :valid_until, :date
    field :gtfs_feed_id, :string
    field :source_sha256, :string
    field :import_version, :integer
    field :source_url, :string

    field :status, Ecto.Enum,
      values: [:pending, :importing, :active, :archived],
      default: :pending

    many_to_many :agencies, TransitWatch.GTFS.Agency, join_through: "gtfs_feed_versions_agencies"

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(feed_version, attrs) do
    feed_version
    |> cast(attrs, [
      :publisher_name,
      :publisher_url,
      :publisher_feed_version,
      :valid_from,
      :valid_until,
      :gtfs_feed_id,
      :source_sha256,
      :import_version,
      :source_url,
      :status
    ])
    |> validate_required([:source_sha256, :import_version, :source_url, :status])
    |> unique_constraint(:source_sha256)
    |> unique_constraint(:import_version)
  end
end
