defmodule EmailSystem.Tags.HorizontalLine do
  import Seml.Context, only: [is_compiler: 2]
  @behaviour Seml.Tag

  @impl true
  def name, do: :horizontal_line

  @impl true
  def compile(_tag, _compile, context) when is_compiler(context, EmailSystem.Compilers.HTML) do
    "<hr/>"
  end

  def compile(_tag, _compile, context) when is_compiler(context, EmailSystem.Compilers.Text) do
    "\n_______________________\n"
  end
end
