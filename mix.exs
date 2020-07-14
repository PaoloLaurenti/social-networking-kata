defmodule SocialNetworkingKata.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :social_networking_kata,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: [
        plt_file: {:no_warn, "_build/dialyzer.plt"},
        plt_add_deps: :app_tree,
        plt_add_apps: [],
        flags: [:error_handling, :underspecs, :unknown, :unmatched_returns]
      ],
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
      # mod: {SocialNetworkingKata.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:git_hooks, "~> 0.4.2", only: [:dev, :test], runtime: false},
      {:hammox, "~> 0.2", only: :test},
      {:domo, "~> 1.0"}
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]

  defp escript do
    [main_module: SocialNetwork.Cli]
  end

  defp aliases do
    [
      test: "test --no-start --trace",
      code_quality: ["format --check-formatted", "credo --strict", "dialyzer"]
    ]
  end
end
