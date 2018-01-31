defmodule TwitFlow.ProducerSupervisor do
  use Supervisor

  @moduledoc """
  Supervisor that will handle failures and restart of the producer.

  The producer will take care of providing a stream of tweets from an external
  resource. For this reason it may fail and needs to be as isolated as possible.
  """

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = []

    opts = [strategy: :one_for_one, name: __MODULE__]
    supervise(children, opts)
  end
end
