defmodule Completex.StubTest do
  @moduledoc false
  use ExUnit.Case

  alias Completex.ChatCompletion.Stub

  describe "should translate something" do
    test "translate" do
      assert Completex.ChatCompletion.call({:chunk, "Привет"}, engine: Stub) ==
               "Hi, I am Stub. Your request echo: Привет"
    end
  end
end
