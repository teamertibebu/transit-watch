defmodule TransitWatch.Repo.Migrations.UpdateGtfsShapeIdOnShapes do
  use Ecto.Migration

  def up do
    alter table("gtfs_shapes") do
      modify :gtfs_shape_id, :string
    end
  end

  def down do
    execute("""
      ALTER TABLE gtfs_shapes
      ALTER COLUMN gtfs_shape_id TYPE integer
      USING gtfs_shape_id::integer
    """)
  end
end
