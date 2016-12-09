defmodule Kitto.Mixfile do
  use Mix.Project

  def project do
    [app: :kitto,
     version: "0.3.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [
       "coveralls": :test,
       "coveralls.detail": :test,
       "coveralls.post": :test,
       "coveralls.travis": :test,
       "coveralls.html": :test],
     name: "Kitto",
     source_url: "https://github.com/kittoframework/kitto",
     docs: [main: "kitto"]
    ]
  end

  def application do
    [mod: {Kitto, []},
     applications: [:logger]]
  end

  defp deps do
    [{:cowboy, "~> 1.0.0"},
     {:plug, "~> 1.2"},
     {:poison, "~> 3.0"},
     {:fs, github: "kittoframework/fs", tag: "v1.9-kitto-1"},
     {:httpoison, "~> 0.10.0"},
     {:ex_doc, "~> 0.14", only: :dev},
     {:credo, "~> 0.5", only: [:dev, :test]},
     {:mock, "~> 0.2", only: :test},
     {:excoveralls, "~> 0.5", only: :test},
     {:inch_ex, "~> 0.5", only: :docs}]
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
