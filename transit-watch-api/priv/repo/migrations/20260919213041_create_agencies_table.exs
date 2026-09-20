defmodule TransitWatch.Repo.Migrations.CreateAgenciesTable do
  use Ecto.Migration

  def change do
    create table(:agencies) do
      add :gtfs_agency_id, :string, null: false
      add :name, :string, null: false
      add :main_url, :string, null: false
      add :fare_url, :string, null: false
      add :timezone, :string, null: false
      add :phone, :string, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:agencies, [:gtfs_agency_id])
    create unique_index(:agencies, [:name])
  end
end
