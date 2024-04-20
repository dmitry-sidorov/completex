defmodule Completex.GoogleBertTest do
  @moduledoc false
  use ExUnit.Case

  alias Completex.ChatCompletion.GoogleT5

  describe "google T5 model" do
    @tag timeout: :infinity
    test "should translate" do
      name = :test
      GoogleT5.start_link(name: name)

      [results: [%{text: text, token_summary: _}]] =
        Completex.ChatCompletion.call("This is a text for translation",
          engine: GoogleT5,
          name: name
        )

      assert text == "Dieser Text ist für die Übersetzung gültig."
    end
  end
end
