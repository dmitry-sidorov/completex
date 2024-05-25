defmodule CompletexWeb.ChatsLive.Index do
  use CompletexWeb, :live_view
  alias Completex.ChatCompletion.GoogleT5

  @impl true
  def mount(_params, _session, socket) do
    {:ok, clear_state(socket)}
  end

  @impl true
  def handle_event("submit", %{"content" => content}, socket) do
    pid = self()

    socket =
      socket
      |> assign(:running, true)
      |> assign(:message_to_translate, content)
      |> start_async(:chat_completion, fn ->
        run_chat_completion(pid, content)
      end)

    {:noreply, socket}
  end

  def handle_event("clear", _payload, socket) do
    {:noreply, clear_state(socket)}
  end

  @impl true
  def handle_info({:chunk, chunk}, socket) do
    {:noreply, assign(socket, :translated_message, chunk)}
  end

  @impl true
  def handle_async(:chat_completion, result, socket) do
    {:noreply, assign(socket, :running, false)}
  end

  defp run_chat_completion(pid, message_to_translate) do
    result =
      Completex.ChatCompletion.call(
        message_to_translate,
        engine: GoogleT5,
        name: GoogleT5,
        callback: fn chunk ->
          case chunk do
            [results: [%{text: content, token_summary: _}]] ->
              send(pid, {:chunk, content})

            _ ->
              nil
          end
        end
      )

    result
  end

  defp clear_state(socket) do
    socket
    |> assign(:message_to_translate, nil)
    |> assign(:translated_message, nil)
    |> assign(:running, false)
  end
end
