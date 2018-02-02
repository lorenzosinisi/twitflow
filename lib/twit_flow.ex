defmodule TwitFlow do
  @moduledoc """
  TwitFlow application responsible for logging tweets matching a specific keyword.
  """
  use Application

  @doc """
  Start the application TwitFlow.
  """
  @spec start(any(), any()) :: {:ok, pid()} | {:error, any()}
  def start(_type, _args) do
    import Supervisor.Spec

    hashtag = monitornig_hashtag()

    children = [
      supervisor(
        TwitFlow.ProducerSupervisor,
        [],
        id: :producer
      ),
      supervisor(
        TwitFlow.ConsumerSupervisor,
        ["Pipeline", hashtag, 10, TwitFlow.Producer],
        id: :consumer
      )
    ]

    opts = [strategy: :rest_for_one, name: ApplicationSupervisor]
    Supervisor.start_link(children, opts)
  end

  defp monitornig_hashtag(), do: System.get_env("MONITOR_HASHTAG") || "startup"
end
