defmodule TransitWatch.Repo.Migrations.CreateTripsTable do
  use Ecto.Migration

  def change do
    create table("shapes") do
      add :gtfs_shape_id, :integer, null: false
      add :shape_pt_lat, :float, null: false
      add :shape_pt_lon, :float, null: false
      add :shape_pt_sequence, :integer, null: false
      add :shape_dist_traveled, :float
    end

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
