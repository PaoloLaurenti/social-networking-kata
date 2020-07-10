defmodule SocialNetworkingKata.Social.SocialNetworkSupervisor do
  @moduledoc """
  The supervisor that namages dinamically the start/stop of the users processes
  supervisor
  """
  use DynamicSupervisor
  alias SocialNetworkingKata.Social.Users.User
  alias SocialNetworkingKata.Social.Users.UsersSupervisor

  @spec start_link(args :: []) :: Supervisor.on_start()
  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  @spec init(args :: []) :: {:ok, DynamicSupervisor.sup_flags()}
  def init(args) do
    DynamicSupervisor.init(strategy: :one_for_one, extra_arguments: args)
  end

  @spec start_user(user :: User.t()) :: DynamicSupervisor.on_start_child()
  def start_user(user) do
    spec = {UsersSupervisor, [user: user]}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
