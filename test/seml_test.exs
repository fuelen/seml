defmodule SemlTest do
  use ExUnit.Case
  doctest Seml

  test "greets the world" do
    assert Seml.hello() == :world
  end
end
