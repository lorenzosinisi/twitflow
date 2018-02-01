defmodule TwitFlow.ProducerConsumer do
  use GenStage
  require Logger

  @moduledoc """
  Subscribes to the Producer, get the messages and discards the ones that are not relevant.
  """

  @doc """
  Part of a specific pipeline, this producer_consumer is responsible for
  asking the producer for more messages. It connects to a given producer on startup.
  """
  def start_link(pipeline_name, hashtag, max_demand, producer) do
    process_name = Enum.join([pipeline_name, "ProducerConsumer"], "")

    GenStage.start_link(
      __MODULE__,
      [hashtag, max_demand, producer],
      name: String.to_atom(process_name)
    )
  end

  @doc """
  Specify the stage as :producer_consumer and subscribe to the producer passed
  as parameter.

  The params are: ```[hashtag, max_demand, producer]```

  ```hashtag``` is a string we want to filer whe iterating over messages.

  ```max_demand``` is a max number of tweets that the producer should try to send.

  ```producer``` is a module set in configuration, that should be a GenStage producer.
  """
  @spec init(List.t()) ::
          {:producer_consumer, String.t(),
           subscribe_to: [{atom(), min_demand: number(), max_demand: number()}]}
  def init([hashtag, max_demand, producer]) do
    Logger.info("Start monitoring tweets about #{hashtag}")

    {:producer_consumer, hashtag,
     subscribe_to: [{producer, min_demand: 0, max_demand: max_demand}]}
  end

  @doc false
  def handle_events(events, _from, hashtag) when is_binary(hashtag) do
    hashtag_events =
      events
      |> Stream.filter(&text/1)
      |> Stream.filter(&valid?(&1, hashtag))
      |> Enum.to_list()

    {:noreply, hashtag_events, hashtag}
  end

  defp text(%{"text" => _tweet}), do: true
  defp text(_any), do: false

  defp valid?(%{"text" => tweet}, hashtag) when is_binary(tweet) and is_binary(hashtag) do
    tweet =~ hashtag
  end

  defp valid?(_, _), do: false
end
