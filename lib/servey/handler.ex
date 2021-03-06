defmodule Servey.Handler do
  @moduledoc """
  Handles HTTP requests.
  """

  #  Alias the module so it can be called as Bar instead of Foo.Bar
  # alias Foo.Bar, as: Bar

  # Require the module in order to use its macros
  # require Foo

  # Import functions from Foo so they can be called without the `Foo.` prefix
  # import Foo

  # Invokes the custom code defined in Foo as an extension point
  # use Foo

  alias Servey.Conv
  alias Servey.BearController
  alias Servey.PledgeController

  # Instead of importing everything, we import only those we need (the numbers indicate function arity)
  import Servey.Plugins, only: [rewrite_path: 1, log: 1, track: 1, put_content_length: 1]
  import Servey.Parser, only: [parse: 1]
  import Servey.FileHandler, only: [file_reader: 2]
  import Servey.View, only: [render: 3]
  # import SomeModule, only: :functions
  # import SomeModule, only: :macros

  # defmacro return(value) do
  #   quote do
  #     unquote(value)
  #   end
  # end

  @doc """
  Transforms the request into a respone.
  """
  def handle(request) do
    request
    |> parse
    |> rewrite_path()
    |> log()
    |> route
    |> track()
    |> put_content_length
    |> format_response
  end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    PledgeController.create(conv)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    PledgeController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/sensors"} = conv) do
    %{location: where_is_bigfoot, snapshots: snapshots} = Servey.SensorServer.get_sensor_data()

    render(conv, "sensors.eex", snapshots: snapshots, location: where_is_bigfoot)
  end

  def route(%Conv{method: "GET", path: "/kaboom"} = _conv) do
    raise "Kaboom!"
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    time
    |> String.to_integer()
    |> :timer.sleep()

    %{conv | status: 200, resp_body: "Awake!"}
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servey.Api.BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    BearController.new(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.delete(conv, params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servey.Api.BearController.create(conv)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    file_reader("about", conv)
  end

  def route(%Conv{method: "GET", path: "/pages/" <> file} = conv) do
    file_reader(file, conv)
  end

  def route(%Conv{path: path} = conv) do
    %{conv | resp_body: "No #{path} here!", status: 404}
  end

  @doc """
  Formats the response into an expected HTTP response string
  """
  def format_response(%Conv{resp_body: resp_body} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{resp_body}
    """
  end

  defp format_response_headers(%Conv{resp_headers: resp_headers}) do
    for {key, value} <- resp_headers do
      "#{key}: #{value}\r"
    end
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.join("\n")
  end
end
