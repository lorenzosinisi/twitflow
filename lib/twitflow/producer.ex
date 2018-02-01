defmodule TwitFlow.Producer do
  use GenStage
  require Logger

  @moduledoc """
  Taking advantage of GenStage, this module acts as producer, setting the stream
  of data coming from Twitter in his own state and using it on demand.

  The connection with Twitter happens asyncronously and if it fails, the server will
  try to reconnect for indefinitely.
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
    schedule_streaming()
    {:producer, default_tweets}
  end

  @doc """
  Callback that receives a numberic demand, takes N element from the twitter
  stream and broadcast those N number of tweets for the consumers.
  """
  @spec handle_demand(number(), Stream.t()) :: {:noreply, List.t(), Stream.t()}
  def handle_demand(demand, stream) when demand > 0 do
    tweets = stream |> Enum.take(demand)

    {:noreply, tweets, stream}
  end

  @doc """
  The init function casts a :start_streaming message to itself.
  In this way starting the connection with the twitter API is asyncronous and
  does not block the app on startup.
  This function wraps the dangerous call to Twitter in a try catch and handles
  the bad connections waiting for 1 second each time.
  """
  def handle_cast(:start_streaming, state) do
    streaming =
      try do
        twitter_handler().stream()
      rescue
        _error ->
          Logger.error("There was an error connecting to the Twitter API.")
      end

    case streaming do
      {:ok, stream} ->
        Logger.info("Start streaming the Twitter APIs.")
        {:noreply, [], stream}

      _otherwise ->
        self()
        |> Process.send_after(:restart_streaming, 50)

        {:noreply, [], state}
    end
  end

  def handle_info(:restart_streaming, state) do
    GenServer.cast(self(), :start_streaming)
    {:noreply, [], state}
  end

  defp schedule_streaming() do
    GenServer.cast(self(), :start_streaming)
  end

  defp twitter_handler() do
    Application.fetch_env!(:twit_flow, :twitter_handler)
  end
end
