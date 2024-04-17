defmodule CompletexWeb.ChatsLive.Index do
  use CompletexWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:messages, [])
      |> assign(:running, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("submit", %{"content" => content}, socket) do
    message = %{role: :user, content: content}
    messages = [message | socket.assigns.messages]
    pid = self()

    socket =
      socket
      |> assign(:running, true)
      |> assign(:messages, messages)
      |> start_async(:chat_completion, fn ->
        run_chat_completion(pid, Enum.reverse(messages))
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:chunk, chunk}, socket) do
    messages =
      case socket.assigns.messages do
        [%{role: :assistant, content: content} | messages] ->
          [%{role: :assistant, content: content <> chunk} | messages]

        messages ->
          [%{role: :assistant, content: chunk} | messages]
      end

    {:noreply, assign(socket, :messages, messages)}
  end

  @impl true
  def handle_async(:chat_completion, _result, socket) do
    {:noreply, assign(socket, :runnning, false)}
  end

  defp run_chat_completion(pid, messages) do
    request = %{messages: messages}

    Completex.ChatCompletion.GoogleBert.call(request,
      callback: fn chunk ->
        case chunk do
          content when is_binary(content) -> send(pid, {:chunk, content}) |> dbg()
          _ -> nil
        end
      end
    )
  end
end
