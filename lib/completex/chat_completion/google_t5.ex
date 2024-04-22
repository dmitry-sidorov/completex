defmodule Completex.ChatCompletion.GoogleT5 do
  @moduledoc """
    Module for translation from RU to EN.
    Model: https://huggingface.co/google-t5/t5-3b
  """
  use GenServer

  def start_link(opts \\ []) do
    {name, opts} = opts |> Keyword.put_new(:name, __MODULE__) |> Keyword.pop!(:name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @impl GenServer
  @spec init(keyword()) :: {:ok, %{serving: Nx.Serving.t()}}
  def init(opts) do
    {model_base, _opts} =
      Keyword.pop(opts, :model, {:hf, "google-t5/t5-small"})

    {:ok, model_info} =
      Bumblebee.load_model(model_base,
        module: Bumblebee.Text.T5,
        architecture: :for_conditional_generation
      )

    {:ok, tokenizer} = Bumblebee.load_tokenizer(model_base)
    {:ok, generation_config} = Bumblebee.load_generation_config(model_base)

    serving =
      Bumblebee.Text.generation(model_info, tokenizer, generation_config)

    {:ok, %{serving: serving}}
  end

  @impl GenServer
  def handle_call({:serve, prompt}, _from, %{serving: serving} = state) do
    {:reply, Nx.Serving.run(serving, prompt) |> Enum.to_list(), state}
  end

  @behaviour Completex.ChatCompletion

  @impl Completex.ChatCompletion
  def call(request, opts) do
    {callback, opts} = Keyword.pop(opts, :callback)
    {name, _opts} = Keyword.pop(opts, :name, __MODULE__)
    response = GenServer.call(name, {:serve, request}, :infinity) |> dbg()

    case callback do
      f when is_function(f, 1) -> f.(response)
      _ -> response
    end
  end
end
