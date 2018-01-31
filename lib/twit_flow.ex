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

    children = [
      supervisor(
        TwitFlow.ProducerSupervisor,
        [],
        id: :producer
      )
    ]

    opts = [strategy: :rest_for_one, name: ApplicationSupervisor]
    Supervisor.start_link(children, opts)
  end
end
