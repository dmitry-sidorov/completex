defmodule Completex.ChatCompletion.Stub do
  @moduledoc """
  Stub implementation to check.
  """
  @behaviour Translatex.ChatCompletion

  @impl Translatex.ChatCompletion
  def call(request, _opts) do
    "Hi, I am Stub. Your request echo: #{request}"
  end
end
