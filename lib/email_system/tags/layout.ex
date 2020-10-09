defmodule EmailSystem.Tags.Layout do
  import Seml.Context, only: [is_compiler: 2]
  @behaviour Seml.Tag

  @impl true
  def name, do: :layout

  @impl true
  def compile(tag, compile, context) when is_compiler(context, EmailSystem.Compilers.HTML) do
    [
      "<html><head><style></style></head><body>",
      compile.(tag.children, compile, context),
      "</body></html>"
    ]
  end

  def compile(tag, compile, context) when is_compiler(context, EmailSystem.Compilers.Text) do
    compile.(tag.children, compile, context)
  end
end
