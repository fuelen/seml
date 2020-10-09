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

      defmacro unquote(name)(children_or_attrs \\ nil, maybe_children \\ nil) do
        {attrs, children} = Seml.System.extract_children(children_or_attrs, maybe_children)
        name = unquote(name)
        implementation = unquote(implementation)

        quote bind_quoted: [
                name: name,
                attrs: attrs,
                children: children,
                implementation: implementation
              ] do
          %Seml.Tag{
            implementation: implementation,
            name: name,
            attributes: Map.new(attrs),
            children: children,
            stacktrace: self() |> Process.info(:current_stacktrace) |> elem(1) |> tl()
          }
        end
      end
    end
  end

  @empty_attributes quote(do: %{})

  @doc false
  def extract_children(children_or_attrs, maybe_children) do
    case {children_or_attrs, maybe_children} do
      {[{:do, {:__block__, _, children}}], _} -> {@empty_attributes, children}
      {[{:do, children}], _} -> {@empty_attributes, List.wrap(children)}
      {attrs, [{:do, {:__block__, _, children}}]} -> {wrap_attributes(attrs), children}
      {attrs, [{:do, children}]} -> {wrap_attributes(attrs), List.wrap(children)}
      {[{_, _} | _] = attrs, nil} -> {attrs, []}
      {children, nil} -> {@empty_attributes, List.wrap(children)}
      {attrs, children} -> {wrap_attributes(attrs), List.wrap(children)}
    end
  end

  defp wrap_attributes(nil), do: @empty_attributes
  defp wrap_attributes([]), do: @empty_attributes
  defp wrap_attributes(attributes), do: attributes
end
