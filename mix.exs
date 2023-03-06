defmodule IGC.MixProject do
  use Mix.Project

  def project do
    [
      app: :igc,
      version: "1.0.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "IGC file parser"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:snapshy, "~> 0.2"}
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/albertorestifo/igc"}
    ]
  end
end
