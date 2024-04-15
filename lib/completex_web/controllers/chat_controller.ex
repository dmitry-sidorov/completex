defmodule CompletexWeb.ChatController do
  use CompletexWeb, :controller

  @json_content_type "application/x-ndjson"

  def stream(conn, %{"request" => request}) do
    conn = conn |> put_resp_content_type(@json_content_type) |> send_chunked(200)

    Completex.ChatCompletion.call(request,
      callback: fn data ->
        result = Jason.encode!(data)
        chunk(conn, result)
        chunk(conn, "\n")
      end
    )

    conn
  end
end
