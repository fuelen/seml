defmodule Seml.Tag do
  @enforce_keys [:name, :attributes, :content, :implementation]
  defstruct [:name, :attributes, :content, :implementation, :stacktrace]

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%Seml.Tag{name: name, attributes: attributes, content: content}, opts) do
      attributes = if attributes == %{}, do: empty(), else: to_doc(attributes, opts)
      content = if content in [nil, "", []], do: empty(), else: to_doc(content, opts)

      details =
        case {attributes, content} do
          {:doc_nil, :doc_nil} -> empty()
          {:doc_nil, content} -> content
          {attributes, :doc_nil} -> attributes
          {attributes, content} -> glue(attributes, content)
        end

      concat(["#", to_string(name), "<", details, ">"])
    end
  end

  @callback name() :: atom()
  @callback compile(compile_fn :: fun(), term(), map()) :: term()
  @callback attributes_analyzer() :: Seml.Tag.Analyzer.t()
  @callback content_analyzer() :: Seml.Tag.Analyzer.t()
  @callback context_analyzer() :: Seml.Tag.Analyzer.t()

  @optional_callbacks attributes_analyzer: 0, content_analyzer: 0, context_analyzer: 0
end
