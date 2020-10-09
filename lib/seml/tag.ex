defmodule Seml.Tag do
  @enforce_keys [:name, :attributes, :children, :implementation]
  defstruct [:name, :attributes, :children, :implementation, :stacktrace]

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%Seml.Tag{name: name, attributes: attributes, children: children}, opts) do
      attributes = if attributes == %{}, do: empty(), else: to_doc(attributes, opts)
      children = if children in [nil, "", []], do: empty(), else: to_doc(children, opts)

      details =
        case {attributes, children} do
          {:doc_nil, :doc_nil} -> empty()
          {:doc_nil, children} -> children
          {attributes, :doc_nil} -> attributes
          {attributes, children} -> glue(attributes, children)
        end

      concat(["#", to_string(name), "<", details, ">"])
    end
  end

  @callback name() :: atom()
  @callback compile(compile_fn :: fun(), term(), map()) :: term()
  @callback attributes_analyzer() :: Seml.Tag.Analyzer.t()
  @callback children_analyzer() :: Seml.Tag.Analyzer.t()
  @callback context_analyzer() :: Seml.Tag.Analyzer.t()

  @optional_callbacks attributes_analyzer: 0, children_analyzer: 0, context_analyzer: 0
end
