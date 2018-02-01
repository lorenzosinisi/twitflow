defmodule TwitFlow.ConsumerSupervisor do
  use Supervisor

  def start_link(name, word, demand) do
    Supervisor.start_link(__MODULE__, [name, word, demand], name: String.to_atom(name))
  end

  def init([pipeline_name, word, demand]) do
    children = []

    opts = [strategy: :one_for_one, name: pipeline_name]
    supervise(children, opts)
  end
end
