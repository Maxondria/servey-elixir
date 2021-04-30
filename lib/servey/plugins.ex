defmodule Servey.Plugins do
  @moduledoc """
  Module responsible for defining conversation transformers
  but not necessarily related to HTML
  """

  # Requires a module in order to use its macros.
  require Logger

  alias Servey.Conv

  @doc """
  Adds emojies to requests that were successful
  """
  def emojify(%Conv{status: 200, resp_body: resp_body} = conv) do
    emojies = String.duplicate("🎉", 5)
    body = emojies <> "\n" <> resp_body <> "\n" <> emojies
    %{conv | resp_body: body}
  end

  def emojify(%Conv{} = conv), do: conv

  @doc """
  Logs 404 requests
  """
  def track(%Conv{status: 404, path: path} = conv) do
    Logger.info("Warning: #{path} is on the loose!")
    conv
  end

  def track(%Conv{} = conv), do: conv

  @doc """
  Redirects "/wildlife" to "/wildthings"
  """
  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%Conv{} = conv), do: conv

  @doc """
  Logs HTTP requests post parsing
  """
  def log(%Conv{} = conv), do: IO.inspect(conv)
end
