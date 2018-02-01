defmodule TwitFlow.ProducerTest do
  use ExUnit.Case, async: false
  import TwitFlow.Producer

  @moduletag capture_log: true

  defmodule FakeTwittex do
    def stream() do
      {:ok, [:bla, :bla, :bla]}
    end
  end

  defmodule FakeTwittexError do
    def stream() do
      "NOT A GOOD THING"
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

    test "it should set the default state" do
      assert {:producer, [1, 2, 3]} = init([1, 2, 3])
    end

    test "it should send a message to itself with `:start_streaming`" do
      init([])
      assert_receive {:"$gen_cast", :start_streaming}
    end
  end

  describe "handle_demand/2" do
    test "Extract N number of elements from a list as defined in the numberic demand" do
      fake_stream = [1, 2, 3, 4, 5, 6, 7, 8, 9]
      demand = 3

      assert {:noreply, tweets, ^fake_stream} = handle_demand(demand, fake_stream)
      assert Enum.count(tweets) == 3
    end
  end

  describe "handle_cast/2 start streaming successfully" do
    setup do
      old_handler = Application.fetch_env!(:twit_flow, :twitter_handler)
      Application.put_env(:twit_flow, :twitter_handler, FakeTwittex)

      on_exit(fn ->
        Application.put_env(:twit_flow, :twitter_handler, old_handler)
      end)

      :ok
    end

    test "sets the stream in the state" do
      call = handle_cast(:start_streaming, [])
      assert {:noreply, [], [:bla, :bla, :bla]} = call
    end
  end

  describe "handle_cast/2 starting the streaming fails" do
    test "sets the stream in the state" do
      old_handler = Application.fetch_env!(:twit_flow, :twitter_handler)
      Application.put_env(:twit_flow, :twitter_handler, FakeTwittexError)

      call = handle_cast(:start_streaming, [])
      assert {:noreply, [], []} = call
      assert_receive :restart_streaming
      Application.put_env(:twit_flow, :twitter_handler, old_handler)
    end
  end
end
