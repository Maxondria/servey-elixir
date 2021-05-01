defmodule Servey do
  def hello(name) do
    "Hello, #{name}"
  end

  # Pracitising Recursion
  def triple([h | t], tripled) do
    triple(t, tripled ++ [h * 3])
  end

  def triple([], tripled), do: tripled
end
