defmodule TransitWatch.Repo.Migrations.CreateRoutesTable do
  use Ecto.Migration

  def change do
    create table(:routes) do
      add :gtfs_route_id, :integer, null: false
      add :agency_id, references("agencies")
      add :route_short_name, :string
      add :route_long_name, :string
      add :route_desc, :text
      add :route_url, :string
      add :route_color, :string
      add :route_text_color, :string

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:routes, [:gtfs_route_id])
  end
end
