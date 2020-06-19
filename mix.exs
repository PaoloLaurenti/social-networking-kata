defmodule SocialNetworkingKata.MixProject do
  use Mix.Project

  def project do
    [
      app: :social_networking_kata,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_file: {:no_warn, "_build/dialyzer.plt"},
        plt_add_deps: :app_tree,
        plt_add_apps: [],
        flags: [:error_handling, :underspecs, :unknown, :unmatched_returns]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SocialNetworkingKata.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:git_hooks, "~> 0.4.2", only: [:test, :dev], runtime: false}
    ]
  end
end
