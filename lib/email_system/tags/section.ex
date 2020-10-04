defmodule EmailSystem.Tags.Section do
  import Seml.Context, only: [is_compiler: 2]
  @behaviour Seml.Tag

  @impl true
  def name, do: :section

  @impl true
  def compile(tag, compile, context) when is_compiler(context, EmailSystem.Compilers.HTML) do
    ["<section>", compile.(tag.content, compile, context), "</section>"]
  end

  def compile(tag, compile, context) when is_compiler(context, EmailSystem.Compilers.Text) do
    compile.(tag.content, compile, context)
  end
end
