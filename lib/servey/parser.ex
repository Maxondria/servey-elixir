defmodule Servey.Parser do
  @moduledoc """
  Module responsible for handling the parsing of HTML strings
  """

  alias Servey.Conv

  @doc """
  Parses the HTTP string to a clean map that routes can then pick up and work with
  """
  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")

    [request_line | header_lines] = String.split(top, "\n")

    [method, path, _] = String.split(request_line, " ")

    params = parse_params(params_string)
    headers = parse_headers(header_lines)

    %Conv{method: method, path: path, params: params, headers: headers}
  end

  def parse_params(param_string) do
    param_string
    |> String.trim()
    |> URI.decode_query()
  end

  # def parse_headers([head | tail], headers \\ %{}) do
  #   [key, value] = String.split(head, ": ")
  #   headers = Map.put(headers, key, value)
  #   parse_headers(tail, headers)
  # end

  # def parse_headers([], headers), do: headers

  def parse_headers(header_lines) do
    Enum.reduce(header_lines, %{}, fn header_line, headers ->
      [key, value] = String.split(header_line, ": ")
      Map.put(headers, key, value)
    end)
  end
end
