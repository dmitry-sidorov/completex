defmodule Completex.ChatCompletion do
  @moduledoc "Behaviour to be implemented by chat completion engines"

  @callback call(any(), keyword()) :: {:ok, String.t()} | {:error, term}
  @callback to_string(term()) :: String.t()

  @optional_callbacks to_string: 1

  def call(request, opts \\ [], engine \\ Completex.ChatCompletion.Stub) do
    {engine, opts} = Keyword.pop(opts, :engine, engine)
    engine.call(request, opts)
  end

  def to_string(output_result, engine) do
    case function_exported?(engine, :to_string, 1) do
      true -> engine.to_string(output_result)
      false -> IO.inspect(output_result)
    end
  end
end
