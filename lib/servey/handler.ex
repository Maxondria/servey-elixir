defmodule Servey.Handler do
  @moduledoc """
  Handles HTTP requests.
  """

  alias Servey.Conv

  # Instead of importing everything, we import only those we need (the numbers indicate function arity)
  import Servey.Plugins, only: [rewrite_path: 1, log: 1, emojify: 1, track: 1]
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
    |> emojify()
    |> track()
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    %{conv | resp_body: "Teddy, Smokey, Paddington", status: 200}
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    file_reader("form", %Conv{} = conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    %{conv | resp_body: "Bear #{id}", status: 200}
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    %{conv | resp_body: "Bear #{id} has been deleted", status: 200}
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    file_reader("about", %Conv{} = conv)
  end

  def route(%Conv{method: "GET", path: "/pages/" <> file} = conv) do
    file_reader(file, %Conv{} = conv)
  end

  def route(%Conv{path: path} = conv) do
    %{conv | resp_body: "No #{path} here!", status: 404}
  end

  @doc """
  Formats the response into an expected HTTP response string
  """
  def format_response(%Conv{resp_body: resp_body} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{byte_size(resp_body)}

    #{resp_body}
    """
  end
end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servey.Handler.handle(request)
IO.puts(response)

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servey.Handler.handle(request)
IO.puts(response)

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servey.Handler.handle(request)
IO.puts(response)

request = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servey.Handler.handle(request)
IO.puts(response)

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servey.Handler.handle(request)
IO.puts(response)

request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servey.Handler.handle(request)
IO.puts(response)

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servey.Handler.handle(request)
IO.puts(response)

request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servey.Handler.handle(request)
IO.puts(response)
