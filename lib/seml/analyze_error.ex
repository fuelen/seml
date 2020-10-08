defmodule Seml.AnalyzeError do
  defexception [:message, :analyzer_name, :tag_name]

  @impl Exception
  def message(exception) do
    "#{exception.analyzer_name} on #{exception.tag_name} tag failed\n#{exception.message}\n"
  end
end
