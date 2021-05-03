defmodule Servey.Api.BearController do
  alias Servey.Conv

  def index(%Conv{} = conv) do
    json =
      Servey.Wildthings.list_bears()
      |> Poison.encode!()

    conv = put_resp_content_type(conv, "application/json")

    %{conv | status: 200, resp_body: json}
  end

  def create(%Conv{params: %{"name" => name, "type" => type}} = conv) do
    %{conv | status: 201, resp_body: "Created a #{type} bear named #{name}!"}
  end

  defp put_resp_content_type(%Conv{resp_headers: resp_headers} = conv, content_type) do
    new_headers = Map.put(resp_headers, "Content-Type", content_type)
    %{conv | resp_headers: new_headers}
  end
end
