defmodule EmailSystem.Tags.Section do
  import Seml.Context, only: [is_compiler: 2]
  @behaviour Seml.Tag

  @impl true
  def name, do: :section

  @impl true
  def compile(props, compile, context) when is_compiler(context, EmailSystem.Compilers.HTML) do
    ["<section>", compile.(props.children, compile, context), "</section>"]
  end

  def compile(props, compile, context) when is_compiler(context, EmailSystem.Compilers.Text) do
    compile.(props.children, compile, context)
  end
end
