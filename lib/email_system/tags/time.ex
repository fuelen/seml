defmodule EmailSystem.Tags.Time do
  import Seml.Context, only: [is_compiler: 2]
  @behaviour Seml.Tag

  @impl true
  def name, do: :time

  @impl true
  def compile(%{attributes: %{format: format, value: value}}, compile, context)
      when is_compiler(context, EmailSystem.Compilers.HTML) do
    ["<time>", compile.(Calendar.strftime(value, format), compile, context), "</time>"]
  end

  def compile(
        %{attributes: %{format: format, value: value}},
        compile,
        context
      )
      when is_compiler(context, EmailSystem.Compilers.Text) do
    value |> Calendar.strftime(format) |> compile.(compile, context)
  end
end
