defmodule TwitFlow.Consumer do
  use GenStage
  require Logger

  @moduledoc """
  This implements a GenStage as consumer and subscribes to a producer.
  It expects the events being a list of maps with the key "text".

  It prints each value of the key text of the event to console using the Logger.
  """

  @doc """
  Consumer part of the supervision tree.
  """
  def start_link(pipeline_name, delay, max_demand) do
    process_name = Enum.join([pipeline_name, "Consumer"], "")

    GenStage.start_link(
      __MODULE__,
      [pipeline_name, delay, max_demand],
      name: String.to_atom(process_name)
    )
  end

  @doc false
  def init([pipeline_name, delay, max_demand]) do
    producer = Enum.join([pipeline_name, "ProducerConsumer"], "")

    {:consumer, [pipeline_name, delay],
     subscribe_to: [{String.to_atom(producer), min_demand: 0, max_demand: max_demand}]}
  end

  def handle_events(events, _from, [pipeline_name, delay]) do
    Process.sleep(delay)

    events
    |> Stream.map(&print/1)
    |> Stream.run()

    {:noreply, [], [pipeline_name, delay]}
  end

  defp print(%{"text" => text, "timestamp_ms" => timestamp_ms}) do
    Logger.info("#{timestamp_ms} -> #{text}")
  end

  defp print(_), do: nil
end
