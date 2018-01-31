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
  def init(default_tweets) do
    {:producer, default_tweets}
  end
end
