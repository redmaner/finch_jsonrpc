defmodule Jsonrpc.MixProject do
  use Mix.Project

  @version "0.2.0"
  @repo_url "https://github.com/redmaner/finch_jsonrpc"

  def project do
    [
      app: :jsonrpc,
      version: @version,
      elixir: "~> 1.10",
      description: "An HTTP JSON-RPC 2.0 client focused on performance, built on Finch.",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: docs(),
      source_url: @repo_url,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/mock_behaviour"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      test: "test --no-start"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:finch, "~> 0.8"},
      {:jason, "~> 1.2"},
      {:injector, "~> 0.2.1"},
      {:mox, "~> 1.0", only: [:test]},
      {:excoveralls, "~> 0.14", only: :test},
      {:ex_doc, "~> 0.25.2", only: [:dev], runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  def package do
    [
      name: :finch_jsonrpc,
      licenses: ["MIT"],
      links: %{"GitHub" => @repo_url}
    ]
  end

  def docs do
    [
      main: "Jsonrpc",
      source_ref: "v#{@version}",
      source_url: @repo_url    ]
  end
end
