defmodule Servey.Parser do
  @moduledoc """
  Module responsible for handling the parsing of HTML strings
  """

  alias Servey.Conv

  @doc """
  Parses the HTTP string to a clean map that routes can then pick up and work with
  """
  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    # We can update structs using like maps, exactly
    # We can pattern match structs like maps,  exactly
    %Conv{method: method, path: path}
  end
end
