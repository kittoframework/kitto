defmodule Kitto.New.Mixfile do
  use Mix.Project

  def project do
    [app: :kitto_new,
     version: "0.1.1",
     elixir: "~> 1.3"]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: []]
  end
end
