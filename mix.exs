defmodule TwitFlow.MixProject do
  use Mix.Project

  def project do
    [
      app: :twit_flow,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Docs
      name: "TwitFlow",
      # The main page in the docs
      docs: [main: "TwitFlow", extras: ["README.md"]]
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
    [
      {:gen_stage, "~> 0.12"},
      {:twittex, "~> 0.3"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end
end
