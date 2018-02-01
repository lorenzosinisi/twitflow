defmodule TwitFlow.ProducerConsumerTest do
  use ExUnit.Case, async: false
  import TwitFlow.ProducerConsumer

  describe "handle_events/3" do
    test "given an empty list, returns an empty list" do
      assert {:noreply, [], "blabla"} = handle_events([], nil, "blabla")
    end

    test "it filters events with a text and matching the hashtag" do
      events = [
        %{"text" => "bitcoin"},
        %{"text" => "bitcoin bitcoin bla bla"},
        %{"test" => "bitcoin but bad key"},
        %{"text" => "just saw a dog"},
        %{}
      ]

      hashtag = "bitcoin"
      process_id = nil
      handle_events(events, process_id, hashtag)

      assert {:noreply, [%{"text" => "bitcoin"}, %{"text" => "bitcoin bitcoin bla bla"}],
              "bitcoin"} = handle_events(events, process_id, hashtag)
    end
  end
end
