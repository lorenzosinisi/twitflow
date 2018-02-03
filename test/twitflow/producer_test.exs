defmodule TwitFlow.ProducerTest do
  use ExUnit.Case, async: false
  import TwitFlow.Producer

  @moduletag capture_log: true

  @tweet %{"text" => "blabla"}

  defmodule FakeTwittex do
    def stream() do
      {:ok, [%{"text" => "blabla"}]}
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

    test "it should set the default state as new queue and remaining demand 0" do
      {:producer, {{[], []}, 0}} = init([1, 2, 3])
    end

    test "it should send a message to itself with `:start_streaming`" do
      init([])
      assert_receive {:"$gen_cast", :start_streaming}
    end
  end

  describe "handle_demand/2" do
    test "Extract N number of elements from a list as defined in the numberic demand" do
      fake_queue = :queue.new()
      demand = 3
      pending_demand = 0

      assert {:noreply, [], {{[], []}, 3}} = handle_demand(demand, {fake_queue, pending_demand})
    end

    test "Extract 1 element when the pending demand is 1" do
      queue = :queue.new()
      queue = :queue.in(@tweet, queue)
      queue = :queue.in(@tweet, queue)
      demand = 3
      pending_demand = 1

      assert {:noreply, [%{"text" => "blabla"}, %{"text" => "blabla"}], {{[], []}, 2}} =
               handle_demand(demand, {queue, pending_demand})
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
      call = handle_cast(:start_streaming, {:queue.new(), 0})
      assert {:noreply, [], {{[], []}, 0}} = call
    end
  end

  describe "handle_cast/2 starting the streaming fails" do
    test "sets the stream in the state" do
      old_handler = Application.fetch_env!(:twit_flow, :twitter_handler)
      Application.put_env(:twit_flow, :twitter_handler, FakeTwittexError)

      call = handle_cast(:start_streaming, {:queue.new(), 0})
      assert {:noreply, [], {{[], []}, 0}} = call
      assert_receive :restart_streaming
      Application.put_env(:twit_flow, :twitter_handler, old_handler)
    end
  end
end
