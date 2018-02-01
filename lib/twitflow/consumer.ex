defmodule TwitFlow.Consumer do
  use GenStage
  require Logger

  def start_link(pipeline_name, delay, max_demand) do
    process_name = Enum.join([pipeline_name, "Consumer"], "")

    GenStage.start_link(
      __MODULE__,
      [pipeline_name, delay, max_demand],
      name: String.to_atom(process_name)
    )
  end

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

  defp print(%{"text" => text}) do
    Logger.info(text)
  end

  defp print(_), do: nil
end
