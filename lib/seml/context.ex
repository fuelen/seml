defmodule Seml.Context do
  defguard is_compiler(context, compiler) when context.__compiler__ == compiler

  def set_compiler(context, compiler) do
    Map.put(context, :__compiler__, compiler)
  end
end
