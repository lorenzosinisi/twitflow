defmodule TwitFlowTest do
  use ExUnit.Case
  doctest TwitFlow

  test "start/2" do
    assert {:ok, _pid} = TwitFlow.start([], [])
  end
end
