defmodule Servey.Parser do
  @moduledoc """
  Module responsible for handling the parsing of HTML strings
  """

  alias Servey.Conv

  @doc """
  Parses the HTTP string to a clean map that routes can then pick up and work with
  """
  def parse(request) do
    [top, params_string] = String.split(request, "\r\n\r\n")

    [request_line | header_lines] = String.split(top, "\r\n")

    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines, %{})
    params = parse_params(headers["Content-Type"], params_string)

    %Conv{method: method, path: path, params: params, headers: headers}
  end

  @doc """
  Parses the given param string of the form `key1=value1&key2=value2`
  into a map with corresponding keys and values

  ## Examples

      iex> params_string = "name=Baloo&type=Brown"
      iex> Servey.Parser.parse_params("application/x-www-form-urlencoded", params_string)
      %{"name" => "Baloo", "type" => "Brown"}
      iex> Servey.Parser.parse_params("multipart/form-data", params_string)
      %{}
  """
  def parse_params("application/x-www-form-urlencoded", param_string) do
    param_string
    |> String.trim()
    |> URI.decode_query()
  end

  def parse_params("application/json", param_string) do
    param_string
    |> Poison.Parser.parse!(%{})
  end

  def parse_params(_, _), do: %{}

  def parse_headers([head | tail], headers) do
    [key, value] = String.split(head, ": ")
    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
  end

  def parse_headers([], headers), do: headers

  # def parse_headers(header_lines) do
  #   Enum.reduce(header_lines, %{}, fn header_line, headers ->
  #     [key, value] = String.split(header_line, ": ")
  #     Map.put(headers, key, value)
  #   end)
  # end
end
