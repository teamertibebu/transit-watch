# lib/my_app_web/live/upload_live.ex
defmodule TransitWatchWeb.ImportLive.Index do
  use TransitWatchWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_feed, nil)
     |> allow_upload(:gtfs_feed,
       accept: ~w(.zip),
       max_entries: 1,
       max_file_size: 250_000_000
     )}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :gtfs_feed, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("upload", _params, socket) do
    [uploaded_feed] =
      consume_uploaded_entries(socket, :gtfs_feed, fn %{path: path}, entry ->
        stored_filename = "#{Ecto.UUID.generate()}.zip"

        destination =
          Path.join([
            Application.app_dir(:transit_watch, "priv/uploads/gtfs_feeds"),
            stored_filename
          ])

        File.mkdir_p!(Path.dirname(destination))
        File.cp!(path, destination)

        {:ok,
         %{
           archive_path: destination,
           original_filename: entry.client_name,
           stored_filename: stored_filename
         }}
      end)

    {:noreply, assign(socket, :uploaded_feed, uploaded_feed)}
  end

  defp upload_error_to_string(:too_large),
    do: "The max file size is currently 250 MB."

  defp upload_error_to_string(:too_many_files),
    do: "Select one GTFS ZIP file."

  defp upload_error_to_string(:not_accepted),
    do: "Select a ZIP file."
end
