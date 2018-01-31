defmodule TwitFlow.ProducerTest do
  use ExUnit.Case
  import TwitFlow.Producer

  describe "init/1" do
    test "when initialized with a non empty list" do
      assert {:producer, [1, 2, 3]} = init([1, 2, 3])
    end

    test "when initialized with an empty list" do
      assert {:producer, []} = init([])
    end
  end
end
