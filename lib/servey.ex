defmodule Servey do
  use Application
  # def hello(name) do
  #   "Hello, #{name}"
  # end

  # # Pracitising Recursion
  # def triple([h | t], tripled) do
  #   triple(t, tripled ++ [h * 3])
  # end

  # def triple([], tripled), do: tripled

  def start(_type, _args) do
    IO.puts("Starting the application...")
    Servey.Supervisor.start_link()
  end
end
