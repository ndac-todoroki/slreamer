defmodule Slreamer.MixProject do
  use Mix.Project

  def project do
    [
      app: :slreamer,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        gcp()
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Slreamer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:plug, "~> 1.10"},
      {:plug_cowboy, "~> 2.3"},
      {:jason, "~> 1.2"},
      {:msgpax, "~> 2.0"},
      {:httpoison, "~> 1.6"},
      {:observer_cli, "~> 1.5"}
    ]
  end

  defp gcp do
    {:gcp,
     [
       include_executables_for: [:unix],
       steps: [:assemble, :tar],
       applications: [runtime_tools: :permanent]
     ]}
  end
end
