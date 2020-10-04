defprotocol EmailSystem.Compilers.HTML.Element do
  def compile(element, compiler, context)
end

defimpl EmailSystem.Compilers.HTML.Element, for: Seml.Tag do
  def compile(element, compiler, context) do
    element.implementation.compile(element, compiler, context)
  end
end

defimpl EmailSystem.Compilers.HTML.Element, for: List do
  def compile(list, compiler, context) do
    for element <- list do
      compiler.(element, compiler, context)
    end
  end
end

defimpl EmailSystem.Compilers.HTML.Element, for: BitString do
  def compile(string, _compiler, _context) do
    string
    |> HtmlEntities.encode()
    |> EmailSystem.Compilers.HTML.nl2br()
  end
end
