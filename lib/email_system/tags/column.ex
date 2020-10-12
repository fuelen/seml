defmodule EmailSystem.Tags.Column do
  import Seml.Context, only: [is_compiler: 2]
  @behaviour Seml.Tag

  @impl true
  def name, do: :column

  @impl true
  def compile(props, compile, context) when is_compiler(context, EmailSystem.Compilers.HTML) do
    ["<div>", compile.(props.children, compile, context), "</div>"]
  end

  def compile(props, compile, context) when is_compiler(context, EmailSystem.Compilers.Text) do
    compile.(props.children, compile, context)
  end
end
