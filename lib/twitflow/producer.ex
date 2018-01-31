defmodule TwitFlow.Producer do
  use GenStage

  @moduledoc """
  Taking advantage of GenStage, this module acts as producer, setting the stream
  of data coming from Twitter in his own state and using it on demand.
  """

  ##########
  # Client API
  ##########
  def start_link(default_tweets) do
    GenStage.start_link(__MODULE__, default_tweets, name: __MODULE__)
  end

  ##########
  # Server callbacks
  ##########

  @doc """
  Start fetching the streaming api of twitter as genstage and set the stream in the state.
  """
  @spec init(List.t()) :: {:producer, Stream.t()} | {:producer, List.t()}
  def init(_default_tweets) do
    handler = twitter_handler()
    {:ok, stream} = handler.stream(:sample, min_demand: 0, max_demand: 100)

    {:producer, stream}
  end

  defp twitter_handler() do
    Application.fetch_env!(:twit_flow, :twitter_handler)
  end
end
