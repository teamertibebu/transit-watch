defmodule TransitWatch.Repo.Migrations.CreateUniqueIndexForTrips do
  use Ecto.Migration

  def change do
    create unique_index(:trips, [:gtfs_trip_id])
  end
end
