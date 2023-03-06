defmodule IGC.MixProject do
  use Mix.Project

  def project do
    [
      app: :igc,
      version: "1.0.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: "IGC file parser",
      package: package(),
      deps: deps()
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
      {:snapshy, "~> 0.2"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  def package do
    [
      name: "igc_parser",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/albertorestifo/igc"}
    ]
  end
end
