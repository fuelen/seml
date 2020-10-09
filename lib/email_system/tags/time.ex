defmodule EmailSystem.Tags.Time do
  import Seml.Context, only: [is_compiler: 2]
  @behaviour Seml.Tag
  import Norm

  @impl Seml.Tag
  def attributes_analyzer do
    selection(
      schema(%{
        format: spec(is_binary()),
        value: spec(is_struct(Time))
      }),
      [:format, :value]
    )
  end

  @impl Seml.Tag
  def children_analyzer do
    spec(Enum.empty?())
  end

  @impl Seml.Tag
  def context_analyzer do
    fn context ->
      if Map.has_key?(context, :pass_context_analyzer) do
        :ok
      else
        {:error, "no #{:pass_context_analyzer} key"}
      end
    end
  end

  @impl Seml.Tag
  def name, do: :time

  @impl Seml.Tag
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
