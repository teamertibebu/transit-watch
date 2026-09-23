defmodule TransitWatch.Repo.Migrations.UpdateRoutesSimplifyNames do
  use Ecto.Migration

  def change do
    rename table("gtfs_routes"), :route_short_name, to: :short_name
    rename table("gtfs_routes"), :route_long_name, to: :long_name
    rename table("gtfs_routes"), :route_desc, to: :description
    rename table("gtfs_routes"), :route_url, to: :url
    rename table("gtfs_routes"), :route_color, to: :designated_color
    rename table("gtfs_routes"), :route_text_color, to: :designated_text_color
  end
end
