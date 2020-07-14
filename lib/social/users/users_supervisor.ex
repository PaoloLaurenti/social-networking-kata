defmodule SocialNetworkingKata.Social.Users.UsersSupervisor do
  @moduledoc """
  The Supervisor of all the processes about the users of the
  """
  use Supervisor
  alias SocialNetworkingKata.ServicesNamesResolver
  alias SocialNetworkingKata.Social.Messages.VolatileMessagesRepository
  alias SocialNetworkingKata.Social.Users.User

  @spec child_spec(user: %User{}) :: Supervisor.child_spec()
  def child_spec(user: %User{} = user) do
    %{
      id: ServicesNamesResolver.get_name(__MODULE__, user.name),
      start: {__MODULE__, :start_link, [[user: user]]},
      type: :supervisor
    }
  end

  @spec start_link(user: %User{}) ::
          {:ok, pid()} | {:error, {:already_started, pid()} | {:shutdown, term()} | term()}
  def start_link(user: user) do
    Supervisor.start_link(__MODULE__, [user: user],
      name: ServicesNamesResolver.get_name(__MODULE__, user.name)
    )
  end

  @impl true
  @spec init(keyword()) :: {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}}
  def init(user: user) do
    children = [{VolatileMessagesRepository, user: user}]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
