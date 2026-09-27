defmodule TransitWatch.Repo.Migrations.UpdateUniqueIndexFeedVersionShapeId do
  use Ecto.Migration

  def up do
    drop_if_exists unique_index("gtfs_shapes", :gtfs_shape_id)
    create_if_not_exists unique_index("gtfs_shapes", [:gtfs_shape_id, :gtfs_feed_version_id])
  end

  def down do
    create_if_not_exists unique_index("gtfs_shapes", :gtfs_shape_id)
    drop_if_exists unique_index("gtfs_shapes", [:gtfs_shape_id, :gtfs_feed_version_id])
  end
end
