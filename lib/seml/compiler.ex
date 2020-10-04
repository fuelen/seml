defmodule Seml.Compiler do
  def compile(element, context, compiler_module) when is_map(context) do
    element_protocol = compiler_module.element_protocol()

    element_protocol.compile(
      element,
      &element_protocol.compile/3,
      Seml.Context.set_compiler(context, compiler_module)
    )
  end

  @callback element_protocol() :: module()
end
