defmodule EmailSystem.Compilers.HTML do
  @behaviour Seml.Compiler

  @impl Seml.Compiler
  def element_protocol, do: EmailSystem.Compilers.HTML.Element

  @doc false
  def nl2br(string) do
    string
    |> String.split("\n")
    |> Enum.intersperse("<br/>")
  end
end
