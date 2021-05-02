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

  # Instead of importing everything, we import only those we need (the numbers indicate function arity)
  import Servey.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servey.Parser, only: [parse: 1]
  import Servey.FileHandler, only: [file_reader: 2]
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
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
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

  def route(%Conv{method: "POST", path: "/bears", params: params} = conv) do
    BearController.create(conv, params)
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
    Content-Type: text/html\r
    Content-Length: #{byte_size(resp_body)}\r
    \r
    #{resp_body}
    """
  end
end

# request = """
# GET /wildthings HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# request = """
# GET /bears HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# response = Servey.Handler.handle(request)
# IO.puts(response)

# request = """
# GET /bears/1 HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# response = Servey.Handler.handle(request)
# IO.puts(response)

# request = """
# DELETE /bears/1 HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# response = Servey.Handler.handle(request)
# IO.puts(response)

# request = """
# GET /bigfoot HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# response = Servey.Handler.handle(request)
# IO.puts(response)

# request = """
# GET /wildlife HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# response = Servey.Handler.handle(request)
# IO.puts(response)

# request = """
# GET /about HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# response = Servey.Handler.handle(request)
# IO.puts(response)

# request = """
# GET /bears/new HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# response = Servey.Handler.handle(request)
# IO.puts(response)

# request = """
# POST /bears HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
# Content-Type: application/x-www-form-urlencoded
# Content-Length: 21

# name=Baloo&type=Brown
# """

# response = Servey.Handler.handle(request)
# IO.puts(response)
