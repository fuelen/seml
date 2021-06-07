defmodule Seml.MixProject do
  use Mix.Project

  def project do
    [
      app: :seml,
      version: "0.1.0",
      elixir: "~> 1.11-dev",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:norm, "~> 0.12.0", optional: true}
    ]
  end
end
