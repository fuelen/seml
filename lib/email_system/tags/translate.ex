defmodule EmailSystem.Tags.Translate do
  @behaviour Seml.Tag

  @impl true
  def name, do: :translate

  @impl true
  def compile(tag, compile, context) do
    assigns = tag.attributes
    warn_on_unknown_pattern? = get_in(context, [:translate, :warn_on_unknown_pattern]) || false

    tag.children
    |> Enum.map(fn
      key_pattern when is_binary(key_pattern) ->
        appearance = Map.fetch!(context, :appearance)

        pattern =
          case Map.fetch(appearance.email_translations, key_pattern) do
            {:ok, pattern} ->
              pattern

            :error ->
              if warn_on_unknown_pattern? do
                IO.warn("pattern #{inspect(key_pattern)} was not found in translations")
              end

              key_pattern
          end

        compile.(eval_template(pattern, assigns), compile, context)

      node ->
        compile.(node, compile, context)
    end)
  end

  # copied from production project
  defp eval_template(pattern, assigns) do
    ~r/%\{\w+?\}/
    |> Regex.split(pattern, include_captures: true, trim: true)
    |> Enum.flat_map(fn
      "%{" <> key_with_ending_tag ->
        key = key_with_ending_tag |> String.trim_trailing("}") |> String.to_existing_atom()

        case Access.fetch(assigns, key) do
          {:ok, value} ->
            [value]

          :error ->
            keys = Enum.map(assigns, &elem(&1, 0))
            IO.warn("Key #{inspect(key)} is not available. Available keys: #{inspect(keys)}")
            []
        end

      string ->
        [string]
    end)
  end
end
