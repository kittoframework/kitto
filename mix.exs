defmodule Kitto.Mixfile do
  use Mix.Project

  def project do
    [app: :kitto,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps]
  end

  def application do
    [mod: {Kitto, []},
     applications: [:logger, :cowboy, :plug]]
  end

  defp deps do
    [{:cowboy, "~> 1.0.0"},
     {:plug, "~> 1.0"},
     {:poison, "~> 2.0"}]
  end

  defp description, do: "Framework for creating interactive dashboards"

  defp package do
    [
      files: ["lib", "mix.exs", "*.md"],
      maintainers: ["Dimitris Zorbas"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/kittoframework/kitto"}
    ]
  end
end
