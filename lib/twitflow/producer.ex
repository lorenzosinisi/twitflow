defmodule TwitFlow.Producer do
  use GenStage
  require Logger

  @moduledoc """
  Taking advantage of GenStage, this module acts as producer, setting the stream
  of data coming from Twitter in his own state and using it on demand.

  The connection with Twitter happens asyncronously and if it fails, the server will
  try to reconnect for indefinitely.

  When the stream is successfully started it will create a new process, sending messages from the stream to
  the current process using the function handle_cast({:enqueue_tweets, tweet}, {queue, pending_demand}).

  This will add new tweets to the queue and pick a number of them to be dispatched based on the
  pending demand.
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
    {:producer, {:queue.new(), 0}}
  end

  @doc """
  Callback that receives a numberic demand, takes N element from the twitter
  stream and broadcast those N number of tweets for the consumers.
  """
  def handle_demand(demand, {queue, pending_demand}) when demand > 0 do
    {reversed_tweets, state} = take_tweets(queue, pending_demand + demand, [])
    {:noreply, Enum.reverse(reversed_tweets), state}
  end

  @doc """
  The init function casts a :start_streaming message to itself.
  In this way starting the connection with the twitter API is asyncronous and
  does not block the app on startup.
  This function wraps the dangerous call to Twitter in a try catch and handles
  the bad connections waiting for 1 second each time.
  """
  def handle_cast(:start_streaming, {queue, pending_demand}) do
    streaming =
      try do
        twitter_handler().stream()
      rescue
        _error ->
          Logger.error("There was an error connecting to the Twitter API.")
      end

    case streaming do
      {:ok, stream} ->
        parent = self()

        spawn_link(fn ->
          Stream.map(stream, fn tweet ->
            tweet = %{"text" => tweet["text"], "timestamp_ms" => tweet["timestamp_ms"]}
            GenServer.cast(parent, {:enqueue_tweets, tweet})
          end)
          |> Stream.run()
        end)

        {:noreply, [], {queue, pending_demand}}

      _otherwise ->
        self()
        |> Process.send_after(:restart_streaming, 50)

        {:noreply, [], {queue, pending_demand}}
    end
  end

  def handle_info(:restart_streaming, {queue, pending_demand}) do
    GenServer.cast(self(), :start_streaming)
    {:noreply, [], {queue, pending_demand}}
  end

  def handle_cast({:enqueue_tweets, tweet}, {queue, pending_demand}) do
    queue = :queue.in(tweet, queue)
    {reversed_jobs, state} = take_tweets(queue, pending_demand, [])
    {:noreply, Enum.reverse(reversed_jobs), state}
  end

  defp take_tweets(queue, 0, tweets), do: {tweets, {queue, 0}}

  defp take_tweets(queue, n, tweets) when n > 0 do
    case :queue.out(queue) do
      {:empty, ^queue} -> {tweets, {queue, n}}
      {{:value, tweet}, queue} -> take_tweets(queue, n - 1, [tweet | tweets])
    end
  end

  defp schedule_streaming() do
    GenServer.cast(self(), :start_streaming)
  end

  defp twitter_handler() do
    Application.fetch_env!(:twit_flow, :twitter_handler)
  end
end
