defmodule Servey.BearController do
  alias Servey.Conv
  alias Servey.Bear
  alias Servey.Wildthings
  import Servey.FileHandler, only: [file_reader: 2]

  defp bear_item(bear) do
    "<li>#{bear.name} - #{bear.type}</li>"
  end

  def index(%Conv{} = conv) do
    items =
      Wildthings.list_bears()
      |> Enum.filter(&Bear.is_grizzly/1)
      |> Enum.sort(&Bear.order_asc_by_name/2)
      |> Enum.map(&bear_item/1)
      |> Enum.join()

    %{conv | resp_body: "<ul>#{items}</ul>", status: 200}
  end

  def show(%Conv{} = conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    %{conv | resp_body: "<h1>Bear #{bear.id}:  #{bear.name}</h1>", status: 200}
  end

  def new(%Conv{} = conv) do
    file_reader("form", conv)
  end

  def delete(%Conv{} = conv, %{"id" => id}) do
    %{conv | resp_body: "Bear #{id} has been deleted", status: 200}
  end

  def create(%Conv{} = conv, %{"name" => name, "type" => type}) do
    %{conv | status: 201, resp_body: "Create a #{type} bear named #{name}!"}
  end
end
