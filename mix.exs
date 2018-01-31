defmodule TwitFlow.MixProject do
  use Mix.Project

  def project do
    [
      app: :twit_flow,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {TwitFlow, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [{:gen_stage, "~> 0.12"}]
  end
end
