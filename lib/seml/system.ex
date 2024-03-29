defmodule Seml.System do
  defmacro deftag(implementation) do
    quote bind_quoted: [implementation: implementation] do
      unless Seml.Tag in Keyword.get(implementation.__info__(:attributes), :behaviour, []) do
        raise "#{implementation} module must implement Seml.Tag behaviour"
      end

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
            props: attrs |> Map.new() |> Map.put(:children, children),
            stacktrace: self() |> Process.info(:current_stacktrace) |> elem(1) |> tl()
          }
        end
      end
    end
  end

  @empty_props quote(do: %{})

  @doc false
  def extract_children(children_or_attrs, maybe_children) do
    case {children_or_attrs, maybe_children} do
      {[{:do, {:__block__, _, children}}], _} -> {@empty_props, children}
      {[{:do, children}], _} -> {@empty_props, List.wrap(children)}
      {attrs, [{:do, {:__block__, _, children}}]} -> {wrap_props(attrs), children}
      {attrs, [{:do, children}]} -> {wrap_props(attrs), List.wrap(children)}
      {[{_, _} | _] = attrs, nil} -> {attrs, []}
      {children, nil} -> {@empty_props, List.wrap(children)}
      {attrs, children} -> {wrap_props(attrs), List.wrap(children)}
    end
  end

  defp wrap_props(nil), do: @empty_props
  defp wrap_props([]), do: @empty_props
  defp wrap_props(props), do: props
end
