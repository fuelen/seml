defmodule EmailSystem.Compilers.Text do
  @behaviour Seml.Compiler

  @impl Seml.Compiler
  def element_protocol, do: EmailSystem.Compilers.Text.Element
end
