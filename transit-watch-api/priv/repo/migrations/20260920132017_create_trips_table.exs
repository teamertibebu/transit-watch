defmodule TransitWatch.Repo.Migrations.CreateTripsTable do
  use Ecto.Migration

  def change do
    create table("shapes") do
      add :gtfs_shape_id, :integer, null: false
    end

    create table("shape_points") do
      add :lat, :float, null: false
      add :long, :float, null: false
      add :sequence, :integer, null: false
      add :distance_traveled, :float
      add :shape_id, references("shapes")
    end

    create unique_index(:shapes, [:gtfs_shape_id])
    create unique_index(:shape_points, [:shape_id, :sequence])

    create table("trips") do
      add :gtfs_trip_id, :integer, null: false
      add :gtfs_route_id, :integer, null: false
      add :gtfs_service_id, :integer, null: false
      add :route_id, references("routes"), null: false
      add :trip_headsign, :string
      add :trip_short_name, :string
      add :direction_id, :integer
      add :block_id, :string
      add :shape_id, references("shapes")
      add :wheelchair_accessible, :integer
      add :bikes_allowed, :integer
    end
  end
end
