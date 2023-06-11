defmodule WebscrapTest do
  use ExUnit.Case
  doctest Webscrap

  test "greets the world" do
    assert Webscrap.hello() == :world
  end
end
