defmodule CredstashEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :credstash_ex,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {CredstashEx.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.0"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_sts, "~> 2.0"},
      {:ex_aws_dynamo, "~> 4.0"},
      {:ex_aws_kms, "~> 2.3"},
      {:poison, "~> 3.0"},
      {:hackney, "~> 1.9"},
      {:configparser_ex, "~> 4.0"},
      {:jsn, "~> 2.2"},
      {:jsx, "~> 3.1"},
      {:dialyxir, "~> 1.3", only: [:dev,:qa], runtime: false},
      {:lettuce, "~> 0.3.0", only: [:dev,:qa]},
      {:mix_unused, "~> 0.1.0"},
    ]
  end
end
