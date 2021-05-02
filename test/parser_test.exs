defmodule ParserTest do
  use ExUnit.Case
  doctest Servey.Parser

  alias Servey.Parser

  test "parses a list of header fields into a map" do
    header_lines = ["A: 1", "B: 2"]
    headers = Parser.parse_headers(header_lines, %{})
    assert headers == %{"A" => "1", "B" => "2"}
  end
end
