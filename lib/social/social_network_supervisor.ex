defmodule SocialNetworkingKata.Social.SocialNetworkSupervisor do
  @moduledoc """
  The supervisor that namages dinamically the start/stop of the users processes
  supervisor
  """
  use DynamicSupervisor
  alias SocialNetworkingKata.Social.Users.UsersSupervisor

  @spec child_spec(args :: any()) :: Supervisor.child_spec()
  def child_spec(args) do
    %{
      id: SocialNetworkSupervisor,
      start: {__MODULE__, :start_link, [args]},
      type: :supervisor
    }
  end

  @spec start_link(args :: any()) :: Supervisor.on_start()
  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  @spec init(args :: []) :: {:ok, DynamicSupervisor.sup_flags()}
  def init(args) do
    DynamicSupervisor.init(strategy: :one_for_one, extra_arguments: args)
  end

  @spec start_user(username :: String.t()) :: DynamicSupervisor.on_start_child()
  def start_user(username) do
    DynamicSupervisor.start_child(__MODULE__, {UsersSupervisor, username: username})
  end
end
