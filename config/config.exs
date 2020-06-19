# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

if Mix.env() != :prod do
  config :git_hooks,
    auto_install: true,
    verbose: true,
    hooks: [
      pre_commit: [
        tasks: [
          "mix format"
        ]
      ],
      pre_push: [
        verbose: false,
        tasks: [
          "mix dialyzer",
          "mix test",
          "echo 'success!'"
        ]
      ]
    ]
end

import_config "#{Mix.env()}.exs"
