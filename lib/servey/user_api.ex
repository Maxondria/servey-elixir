defmodule Servey.UserApi do
  @api_base "https://jsonplaceholder.typicode.com/users/"

  defp fetch_user(id) when is_binary(id) do
    HTTPoison.get(@api_base <> id)
    |> parse_response()
  end

  defp fetch_user(id) when is_integer(id) do
    id
    |> Integer.to_string()
    |> fetch_user()
  end

  defp parse_response({:ok, %{body: body, status_code: 200}}) do
    city =
      Poison.Parser.parse!(body, %{})
      |> get_in(["address", "city"])

    {:ok, city}
  end

  defp parse_response({:ok, %{body: body, status_code: _status}}) do
    message =
      Poison.Parser.parse!(body, %{})
      |> get_in(["message"])

    {:error, message}
  end

  defp parse_response({:error, %{reason: reason}}) do
    {:error, reason}
  end

  def query(id) do
    case fetch_user(id) do
      {:ok, city} ->
        city

      {:error, error} ->
        "Whoops! #{error}"
    end
  end
end
