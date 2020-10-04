defmodule Seml.Tag do
  @enforce_keys [:name, :attributes, :content, :implementation]
  defstruct [:name, :attributes, :content, :implementation]

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
  # @callback allowed_content() :: [{:tags, {:all_except | :only, atom() | nonempty_list(atom())} | :none} | {:values, :all | :none}]
  # @callback compilers() :: [atom()]
  # @callback conform_attributes(map()) :: :ok | {:error, any()}
  @callback compile(compile_fn :: fun(), term(), map()) :: term()
end
