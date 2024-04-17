defmodule Completex.ChatCompletion.Stub do
  @moduledoc """
  Stub implementation to check.
  """
  @behaviour Translatex.ChatCompletion

  @impl Translatex.ChatCompletion
  def call({:chunk, chunk}, opts \\ []) do
    "Hi, I am Stub. Your request echo: #{chunk}"
  end
end
