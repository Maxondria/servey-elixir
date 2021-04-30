defmodule Servey.FileHandler do
  @moduledoc """
  Module responsible for handling of reading files and returning content
  """

  alias Servey.Conv

  # This defines an absolute path to where we keep our files
  @pages_path Path.expand("pages", File.cwd!())

  def file_reader(filename, %Conv{} = conv) do
    @pages_path
    |> Path.join(filename <> ".html")
    |> File.read()
    |> handle_file(conv)
  end

  def handle_file({:ok, content}, %Conv{} = conv) do
    %{conv | resp_body: content, status: 200}
  end

  def handle_file({:error, :enoent}, %Conv{} = conv) do
    %{conv | resp_body: "File not found", status: 404}
  end

  def handle_file({:error, reason}, %Conv{} = conv) do
    %{conv | resp_body: "File error: #{reason}", status: 500}
  end
end
