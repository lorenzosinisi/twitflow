defmodule TwitFlow do
  @moduledoc """
  TwitFlow application responsible for logging tweets matching a specific keyword.
  """
  use Application

  @doc """
  Start the application TwitFlow.
  """
  @spec start(any(), any()) :: {:ok, pid()} | {:error, any()}
  def start(_type, args) do
    import Supervisor.Spec

    children = [
      supervisor(
        TwitFlow.ProducerSupervisor,
        [],
        id: :producer
      ),
      supervisor(
        TwitFlow.ConsumerSupervisor,
        ["BitcoinPipeline", "a", 1, TwitFlow.Producer],
        id: :consumer
      )
    ]

    opts = [strategy: :rest_for_one, name: ApplicationSupervisor]
    Supervisor.start_link(children, opts)
  end
end
