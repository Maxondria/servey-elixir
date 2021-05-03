defmodule Servey.Wildthings do
  alias Servey.Bear

  @db_path Path.expand("db", File.cwd!())

  def list_bears do
    @db_path
    |> Path.join("bears.json")
    |> File.read()
    |> handle_file
    |> Poison.Parser.parse!(%{})
    |> Map.get("bears")
    |> bear_maps_to_bear_structs
  end

  defp handle_file({:error, reason}) do
    IO.inspect("Error reading file:  #{reason}")
    "[]"
  end

  defp handle_file({:ok, contents}), do: contents

  defp bear_maps_to_bear_structs(bears) do
    bears
    |> Enum.map(fn bear ->
      for {key, val} <- bear, into: %{}, do: {String.to_atom(key), val}
    end)
    |> Enum.map(fn bear -> struct(Bear, bear) end)
  end

  def get_bear(id) when is_integer(id) do
    Enum.find(list_bears(), fn bear -> bear.id == id end)
  end

  def get_bear(id) when is_binary(id) do
    id
    |> String.to_integer()
    |> get_bear()
  end
end
