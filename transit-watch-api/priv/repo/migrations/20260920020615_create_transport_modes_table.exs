defmodule TransitWatch.Repo.Migrations.CreateTransportModesTable do
  use Ecto.Migration

  def change do
    create table(:transport_modes) do
      add(:gtfs_route_type, :integer)
      add(:mode, :string)
      add(:description, :string)

      timestamps(type: :utc_datetime_usec)
    end
  end
end
