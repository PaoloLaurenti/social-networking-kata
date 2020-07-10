defmodule SocialNetworkingKata.Social.Users.UsersSupervisor do
  @moduledoc """
  The Supervisor of all the processes about the users of the
  """
  use Supervisor
  alias SocialNetworkingKata.ServicesNamesResolver
  alias SocialNetworkingKata.Social.Users.User
  alias SocialNetworkingKata.Social.VolatileMessagesRepository

  @spec start_link(keyword()) ::
          {:ok, pid()} | {:error, {:already_started, pid()} | {:shutdown, term()} | term()}
  def start_link(user: %User{name: name} = user) do
    Supervisor.start_link(__MODULE__, [user: user],
      name: ServicesNamesResolver.get_name(__MODULE__, name)
    )
  end

  @impl true
  @spec init(keyword()) :: {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}}
  def init(user: user) do
    children = [{VolatileMessagesRepository, user: user}]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
