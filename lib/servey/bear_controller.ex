defmodule Servey.BearController do
  alias Servey.Conv
  alias Servey.Bear
  alias Servey.Wildthings

  import Servey.View, only: [render: 3]
  import Servey.FileHandler, only: [file_reader: 2]

  def index(%Conv{} = conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

    render(conv, "index.eex", bears: bears)
  end

  def show(%Conv{} = conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    render(conv, "show.eex", bear: bear)
  end

  def new(%Conv{} = conv) do
    file_reader("form", conv)
  end

  def delete(%Conv{} = conv, %{"id" => id}) do
    %{conv | resp_body: "Bear #{id} has been deleted", status: 200}
  end

  def create(%Conv{params: %{"name" => name, "type" => type}} = conv) do
    %{conv | status: 201, resp_body: "Created a #{type} bear named #{name}!"}
  end
end
