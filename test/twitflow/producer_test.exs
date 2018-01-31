defmodule TwitFlow.ProducerTest do
  use ExUnit.Case, async: false
  import TwitFlow.Producer

  defmodule FakeTwittex do
    def stream(_, _) do
      {:ok, [:bla, :bla, :bla]}
    end
  end

  describe "init/1" do
    setup do
      old_handler = Application.fetch_env!(:twit_flow, :twitter_handler)

      Application.put_env(:twit_flow, :twitter_handler, FakeTwittex)

      on_exit(fn ->
        Application.put_env(:twit_flow, :twitter_handler, old_handler)
      end)

      :ok
    end

    test "it should set the twitter_handler stream as state" do
      assert {:producer, [:bla, :bla, :bla]} = init([1, 2, 3])
    end
  end
end
