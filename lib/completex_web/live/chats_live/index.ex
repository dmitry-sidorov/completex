defmodule CompletexWeb.ChatsLive.Index do
  use CompletexWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Some text</h1>
    """
  end
end
