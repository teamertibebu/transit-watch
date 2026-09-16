defmodule TransitWatch.Repo do
  use Ecto.Repo,
    otp_app: :transit_watch,
    adapter: Ecto.Adapters.Postgres
end
