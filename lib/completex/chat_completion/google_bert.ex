defmodule Completex.ChatCompletion.GoogleBert do
  @moduledoc """
    Module for translation from RU to EN.
    Model: https://huggingface.co/google-bert/bert-base-uncased
  """
  use GenServer

  @spec start_link(keyword()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(opts \\ []) do
    {name, opts} = opts |> Keyword.put_new(:name, __MODULE__) |> Keyword.pop!(:name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @impl GenServer
  @spec init(keyword()) :: {:ok, %{serving: Nx.Serving.t()}}
  def init(opts) do
    {model_base, _opts} =
      Keyword.pop(opts, :model, {:hf, "google-bert/bert-base-uncased"})

    {:ok, model_info} = Bumblebee.load_model(model_base)
    {:ok, tokenizer} = Bumblebee.load_tokenizer(model_base)
    serving = Bumblebee.Text.fill_mask(model_info, tokenizer)

    {:ok, %{serving: serving}}
  end

  @impl GenServer
  def handle_call({:serve, prompt}, _from, %{serving: serving} = state) do
    {:reply, Nx.Serving.run(serving, prompt) |> Enum.to_list(), state}
  end

  @behaviour Completex.ChatCompletion

  @impl Completex.ChatCompletion
  def call(request, opts) do
    {name, _opts} = Keyword.pop(opts, :name, __MODULE__)
    GenServer.call(name, {:serve, request}, :infinity)
  end
end
