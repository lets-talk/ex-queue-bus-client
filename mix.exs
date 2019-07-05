defmodule ExQueueBusClient.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_queue_bus_client,
      version: "1.0.1",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [ignore_warnings: "dialyzer.ignore"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExQueueBusClient.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_aws, "~> 2.1"},
      {:ex_aws_sqs, "~> 2.0"},
      {:ex_aws_sns, "~> 2.0"},
      {:hackney, "~> 1.9"},
      {:poison, "~> 3.0"},
      {:sweet_xml, "~> 0.6"},
      {:gen_stage, "~> 0.14"},
      {:mox, "~> 0.5", only: [:test]},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false}
    ]
  end
end
