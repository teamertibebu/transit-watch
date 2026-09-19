defmodule TransitWatchWeb.PageController do
  use TransitWatchWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
