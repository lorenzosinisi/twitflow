defmodule TwitFlowTest do
  use ExUnit.Case
  doctest TwitFlow

  test "greets the world" do
    assert TwitFlow.hello() == :world
  end
end
