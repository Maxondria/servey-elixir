defmodule ServeyTest do
  use ExUnit.Case
  doctest Servey

  test "greets the world" do
    assert Servey.hello() == :world
  end
end
