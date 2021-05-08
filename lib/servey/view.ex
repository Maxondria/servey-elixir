defmodule Servey.View do
  alias Servey.Conv
  # This defines an absolute path to where we keep our files
  @templates_path Path.expand("templates", File.cwd!())

  def render(%Conv{} = conv, template, bindings) do
    content =
      @templates_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)

    %{conv | resp_body: content, status: 200}
  end
end
