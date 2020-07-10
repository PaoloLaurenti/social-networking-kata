defmodule SocialNetworkingKata.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias SocialNetworkingKata.Social.SocialNetworkSupervisor

  def start(_type, _args) do
    children = [
      Supervisor.child_spec({Registry, keys: :unique, name: SocialNetworkingKata.Registry},
        id: SocialNetworkingKata.Registry
      ),
      {SocialNetworkSupervisor, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SocialNetworkingKata.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
