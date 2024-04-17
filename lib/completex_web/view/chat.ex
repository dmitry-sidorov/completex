defmodule CompletexWeb.View.Chat do
  use Kino.JS

  def new(html) when is_binary(html) do
    Kino.JS.new(__MODULE__, html)
  end

  def init(opts \\ []) do
    {:ok, opts}
  end

  asset "main.js" do
    """
    export function init(ctx, html) {
      ctx.root.innerHTML = html;
    }
    """
  end
end
