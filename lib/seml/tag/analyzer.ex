defprotocol Seml.Tag.Analyzer do
  def analyze(analyzer, data)
end

defimpl Seml.Tag.Analyzer, for: Function do
  def analyze(function, input) when is_function(function, 1) do
    function.(input)
  end
end

if Code.ensure_loaded?(Norm) do
  defimpl Seml.Tag.Analyzer,
    for: [
      Norm.Core.Alt,
      Norm.Core.AnyOf,
      Norm.Core.Collection,
      Norm.Core.Schema,
      Norm.Core.Selection,
      Norm.Core.Spec
    ] do
    def analyze(spec, input) do
      case Norm.conform(input, spec) do
        {:ok, _} ->
          :ok

        {:error, errors} ->
          {:error, errors |> Norm.MismatchError.exception() |> Exception.message()}
      end
    end
  end
end
