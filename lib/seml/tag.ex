defmodule Seml.Tag do
  @enforce_keys [:name, :props, :implementation]
  defstruct [:name, :props, :implementation, :stacktrace]

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%Seml.Tag{name: name, props: props}, opts) do
      {children, props} = Map.pop(props, :children)
      props = if props == %{}, do: empty(), else: to_doc(props, opts)
      children = if children in [nil, "", []], do: empty(), else: to_doc(children, opts)

      details =
        case {props, children} do
          {:doc_nil, :doc_nil} -> empty()
          {:doc_nil, children} -> children
          {props, :doc_nil} -> props
          {props, children} -> glue(props, children)
        end

      concat(["#", to_string(name), "<", details, ">"])
    end
  end

  @callback name() :: atom()
  @callback compile(term(), compile_fn :: fun(), map()) :: term()
  @callback props_analyzer() :: Seml.Tag.Analyzer.t()
  @callback context_analyzer() :: Seml.Tag.Analyzer.t()

  @optional_callbacks props_analyzer: 0, context_analyzer: 0
end
