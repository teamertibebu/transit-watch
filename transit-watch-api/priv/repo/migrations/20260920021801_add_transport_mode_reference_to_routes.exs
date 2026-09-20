defmodule TransitWatch.Repo.Migrations.AddTransportModeReferenceToRoutes do
  use Ecto.Migration

  def change do
    alter table(:routes) do
      add :transport_mode_id, references("transport_modes")
    end
  end
end
