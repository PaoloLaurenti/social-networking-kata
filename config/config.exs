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
          "mix compile --warnings-as-errors",
          "mix code_quality",
          "echo 'success!'"
        ]
      ]
    ]
end

import_config "#{Mix.env()}.exs"
