defmodule TransitWatch.Repo.Migrations.CreateStopsTable do
  use Ecto.Migration

  def change do
    create table("location_types") do
      add :gtfs_locaton_type, :string
      add :name, :string
      add :desc, :string
    end

    create table("stops") do
      add :gtfs_stop_id, :string
      add :code, :string
      add :name, :string
      add :desc, :string
      add :lat, :float
      add :long, :float
      add :url, :string
      add :parent_station, :string
      add :wheelchair_boarding, :string
      add :location_type_id, references("location_types")

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:stops, [:gtfs_stop_id])
    create unique_index(:location_types, [:gtfs_locaton_type])
  end
end
