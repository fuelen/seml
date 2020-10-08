defmodule Seml.Compiler do
  def compile(element, context, compiler_module, opts \\ []) when is_map(context) do
    element_protocol = compiler_module.element_protocol()
    analysis = Keyword.get(opts, :analysis, :none)

    element_protocol.compile(
      element,
      compiler_callback(element_protocol, analysis),
      Seml.Context.set_compiler(context, compiler_module)
    )
  end

  defp compiler_callback(element_protocol, :none) do
    &element_protocol.compile/3
  end

  defp compiler_callback(element_protocol, analysis) do
    fn element, compiler, context ->
      case element do
        %Seml.Tag{} = tag ->
          tag
          |> analyze(context)
          |> Enum.each(fn
            {_analyzer_name, :not_implemented} ->
              :noop

            {_analyzer_name, :ok} ->
              :noop

            {analyzer_name, {:error, reason}} when is_binary(reason) ->
              error =
                Seml.AnalyzeError.exception(
                  tag_name: tag.name,
                  message: reason,
                  analyzer_name: analyzer_name
                )

              case analysis do
                :warn -> error |> Exception.message() |> IO.warn(tag.stacktrace)
                :raise -> reraise error, tag.stacktrace
              end
          end)

        _ ->
          :noop
      end

      element_protocol.compile(element, compiler, context)
    end
  end

  def analyze(tag, context) do
    for {function_name, input} <- [
          attributes_analyzer: tag.attributes,
          content_analyzer: tag.content,
          context_analyzer: context
        ] do
      if function_exported?(tag.implementation, function_name, 0) do
        analyzer = apply(tag.implementation, function_name, [])

        {
          function_name,
          Seml.Tag.Analyzer.analyze(analyzer, input)
        }
      else
        {function_name, :not_implemented}
      end
    end
  end

  @callback element_protocol() :: module()
end
