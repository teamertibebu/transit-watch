defmodule TransitWatch.Repo.Migrations.RemoveRouteTypeFromRoutesTable do
  use Ecto.Migration

  def up do
    alter table("routes") do
      remove :route_type
      remove :route_type_desc
    end
  end

  def down do
    alter table("routes") do
      add :route_type, :string
      add :route_type_desc, :string
    end
  end
end
