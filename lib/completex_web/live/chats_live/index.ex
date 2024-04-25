defmodule CompletexWeb.ChatsLive.Index do
  use CompletexWeb, :live_view
  alias Completex.ChatCompletion.GoogleT5

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
    IO.inspect(content, label: "SUBMIT BUTTON PRESSED")
    message = %{role: :user, content: content}
    # |> dbg()
    messages = [message | socket.assigns.messages]
    pid = self()

    socket =
      socket
      |> assign(:running, true)
      |> assign(:messages, messages)
      |> start_async(:chat_completion, fn ->
        run_chat_completion(pid, Enum.reverse(messages))
      end)

    # |> dbg()

    {:noreply, socket}
  end

  @impl true
  def handle_info({:chunk, chunk}, socket) do
    # messages =
    #   case socket.assigns.messages do
    #     [%{role: :assistant, content: content} | messages] ->
    #       [%{role: :assistant, content: content <> chunk} | messages]

    #     messages ->
    #       [%{role: :assistant, content: chunk} | messages]
    #   end
    messages = [%{role: :assistant, content: chunk}]

    {:noreply, assign(socket, :messages, messages)}
  end

  @impl true
  def handle_async(:chat_completion, _result, socket) do
    IO.inspect("RUN :chat_completion clause")
    {:noreply, assign(socket, :runnning, false)}
  end

  @imlp true
  def handle_call({:serve, message}, _from, state) do
    {:reply, message, state} |> dbg()
  end

  defp run_chat_completion(pid, messages) do
    messages |> dbg()
    [%{content: content, role: :user}] = messages

    # [results: [%{text: result, token_summary: _}]] =
    result =
      Completex.ChatCompletion.call(
        content,
        engine: GoogleT5,
        name: GoogleT5,
        callback: fn chunk ->
          case chunk do
            [results: [%{text: content, token_summary: _}]] ->
              send(pid, {:chunk, content}) |> dbg()
              send(pid, {:chunk, content})

            _ ->
              nil
          end
        end
      )

    # |> dbg()

    result
  end
end
