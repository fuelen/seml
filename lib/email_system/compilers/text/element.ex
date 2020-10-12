defprotocol EmailSystem.Compilers.Text.Element do
  def compile(element, compiler, context)
end

defimpl EmailSystem.Compilers.Text.Element, for: Seml.Tag do
  def compile(element, compiler, context) do
    element.implementation.compile(element.props, compiler, context)
  end
end

defimpl EmailSystem.Compilers.Text.Element, for: List do
  def compile(list, compiler, context) do
    for element <- list do
      compiler.(element, compiler, context)
    end
  end
end

defimpl EmailSystem.Compilers.Text.Element, for: BitString do
  def compile(string, _compiler, _context) do
    string
  end
end
