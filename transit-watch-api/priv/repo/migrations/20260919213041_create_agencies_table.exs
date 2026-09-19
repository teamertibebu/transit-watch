defmodule TransitWatch.Repo.Migrations.CreateAgenciesTable do
  use Ecto.Migration

  def change do
    create table(:agencies) do
      add :short_name, :string, null: false
      add :long_name, :string, null: false
      add :main_url, :string, null: false
      add :fare_url, :string, null: false
      add :timezone, :string, null: false
      add :phone, :string, null: false
    end

    create unique_index(:agencies, [:short_name])
    create unique_index(:agencies, [:long_name])
  end
end
