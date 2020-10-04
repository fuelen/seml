defmodule EmailSystem.Tags.Column do
  import Seml.Context, only: [is_compiler: 2]
  @behaviour Seml.Tag

  @impl true
  def name, do: :column

  @impl true
  def compile(tag, compile, context) when is_compiler(context, EmailSystem.Compilers.HTML) do
    ["<div>", compile.(tag.content, compile, context), "</div>"]
  end

  def compile(tag, compile, context) when is_compiler(context, EmailSystem.Compilers.Text) do
    compile.(tag.content, compile, context)
  end
end
