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
            content: content
          }
        end
      end
    end
  end

  @doc false
  def warn_on_invalid_content(content, allowed_content, name, stacktrace) do
    allowed_values = Keyword.get(allowed_content, :values, :none)
    allowed_tags = Keyword.get(allowed_content, :tags, :none)
    {tags, values} = Enum.split_with(content, &is_struct(&1, Seml.Tag))

    case {allowed_values, values} do
      {:none, [_ | _]} ->
        IO.warn(
          "invalid content in #{inspect(name)} tag: expected none values, got: #{inspect(values)}",
          stacktrace
        )

      _ ->
        :noop
    end

    case {allowed_tags, tags} do
      {:none, [_ | _]} ->
        tags = tags |> List.wrap() |> Enum.map(& &1.name)

        IO.warn(
          "invalid content in #{inspect(name)} tag: expected none tags, got: #{inspect(tags)}",
          stacktrace
        )

      {{:only, tags_list}, tags} ->
        tags_list = List.wrap(tags_list)

        tags
        |> Enum.map(& &1.name)
        |> Enum.reject(&(&1 in tags_list))
        |> case do
          [] ->
            :noop

          not_allowed_tags ->
            IO.warn(
              "invalid content in #{inspect(name)} tag: expected tags: #{inspect(tags_list)}, got: #{
                inspect(not_allowed_tags)
              }",
              stacktrace
            )
        end

      {{:all_except, tags_list}, tags} ->
        tags_list = List.wrap(tags_list)

        tags
        |> Enum.map(& &1.name)
        |> Enum.filter(&(&1 in tags_list))
        |> case do
          [] ->
            :noop

          not_allowed_tags ->
            IO.warn(
              "invalid content in #{inspect(name)} tag: not expected tags: #{inspect(tags_list)}, got: #{
                inspect(not_allowed_tags)
              }",
              stacktrace
            )
        end

      {:none, []} ->
        :noop
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
