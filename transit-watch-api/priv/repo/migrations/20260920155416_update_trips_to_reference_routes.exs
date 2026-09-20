defmodule TransitWatch.Repo.Migrations.UpdateTripsToReferenceRoutes do
  use Ecto.Migration

  def up do
    alter table("trips") do
      remove :gtfs_route_id
    end
  end

  def down do
    alter table("trips") do
      add :gtfs_route_id, :integer, null: false
    end
  end
end
