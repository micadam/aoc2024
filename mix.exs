defmodule AdventOfCode.MixProject do
  use Mix.Project

  def project do
    [
      app: :advent_of_code,
      version: "0.1.0",
      elixir: "~> 1.17.3",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: AdventCLI],
      deps: deps(),
      test_paths: ["lib"]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:prioqueue, "~> 0.2.0"},
      {:memoize, "~> 1.4"},
    ]
  end
end
