defmodule EmailSystem.Tags.DateTime do
  import Seml.Context, only: [is_compiler: 2]
  import Norm
  @behaviour Seml.Tag

  @impl true
  def name, do: :datetime

  @impl true
  def context_analyzer do
    selection(
      schema(%{
        datetime: schema(%{timezone: spec(is_binary())}),
      }),
      [datetime: [:timezone]]
    )
  end

  @impl true
  def compile(%{attributes: %{value: value} = attrs}, compile, context)
      when is_compiler(context, EmailSystem.Compilers.HTML) do
    tz = Map.get(attrs, :timezone, context.datetime.timezone)
    datetime = DateTime.shift_zone!(value, tz)
    ["<time>", compile.(to_string(datetime), compile, context), "</time>"]
  end

  def compile(%{attributes: %{value: value} = attrs}, compile, context)
      when is_compiler(context, EmailSystem.Compilers.Text) do
    tz = Map.get(attrs, :timezone, context.datetime.timezone)
    datetime = DateTime.shift_zone!(value, tz)
    compile.(to_string(datetime), compile, context)
  end
end
