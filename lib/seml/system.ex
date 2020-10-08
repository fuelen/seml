defmodule Seml.System do
  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :tags, accumulate: true)
      import unquote(__MODULE__)
    end
  end

  defmacro deftag(implementation) do
    quote bind_quoted: [implementation: implementation] do
      unless Seml.Tag in Keyword.get(implementation.__info__(:attributes), :behaviour, []) do
        raise "#{implementation} module must implement Seml.Tag behaviour"
      end

      Module.put_attribute(__MODULE__, :tags, implementation)

      name = implementation.name()

      defmacro unquote(name)(content_or_attrs \\ nil, maybe_content \\ nil) do
        {attrs, content} = Seml.System.extract_content(content_or_attrs, maybe_content)
        name = unquote(name)
        implementation = unquote(implementation)

        quote bind_quoted: [
                name: name,
                attrs: attrs,
                content: content,
                implementation: implementation
              ] do
          %Seml.Tag{
            implementation: implementation,
            name: name,
            attributes: Map.new(attrs),
            content: content,
            stacktrace: self() |> Process.info(:current_stacktrace) |> elem(1) |> tl()
          }
        end
      end
    end
  end

  @empty_attributes quote(do: %{})

  @doc false
  def extract_content(content_or_attrs, maybe_content) do
    case {content_or_attrs, maybe_content} do
      {[{:do, {:__block__, _, content}}], _} -> {@empty_attributes, content}
      {[{:do, content}], _} -> {@empty_attributes, List.wrap(content)}
      {attrs, [{:do, {:__block__, _, content}}]} -> {wrap_attributes(attrs), content}
      {attrs, [{:do, content}]} -> {wrap_attributes(attrs), List.wrap(content)}
      {[{_, _} | _] = attrs, nil} -> {attrs, []}
      {content, nil} -> {@empty_attributes, List.wrap(content)}
      {attrs, content} -> {wrap_attributes(attrs), List.wrap(content)}
    end
  end

  defp wrap_attributes(nil), do: @empty_attributes
  defp wrap_attributes([]), do: @empty_attributes
  defp wrap_attributes(attributes), do: attributes
end
