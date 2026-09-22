defmodule TransitWatch.Repo.Migrations.PrefixGtfsTables do
  use Ecto.Migration

  def change do
    rename table("agencies"), to: table("gtfs_agencies")
    rename table("location_types"), to: table("gtfs_location_types")
    rename table("routes"), to: table("gtfs_routes")
    rename table("shape_points"), to: table("gtfs_shape_points")
    rename table("shapes"), to: table("gtfs_shapes")
    rename table("stops"), to: table("gtfs_stops")
    rename table("transport_modes"), to: table("gtfs_transport_modes")
    rename table("trips"), to: table("gtfs_trips")
  end
end
