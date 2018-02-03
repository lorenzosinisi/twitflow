defmodule TwitFlow.ConsumerSupervisor do
  use Supervisor

  def start_link(pipeline_name, word, demand, producer) do
    Supervisor.start_link(
      __MODULE__,
      [pipeline_name, word, demand, producer],
      name: String.to_atom(pipeline_name)
    )
  end

  def init([pipeline_name, word, demand, producer]) do
    children = [
      worker(TwitFlow.ProducerConsumer, [pipeline_name, word, demand, producer]),
      worker(TwitFlow.Consumer, [pipeline_name, 0, demand])
    ]

    opts = [strategy: :one_for_one, name: pipeline_name]
    supervise(children, opts)
  end
end
