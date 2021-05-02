defmodule ParserTest do
  use ExUnit.Case
  doctest Servey.Parser

  alias Servey.Parser

  test "greets the world" do
    assert Servey.hello() == :world
  end
end
