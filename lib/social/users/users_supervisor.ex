defmodule SocialNetworkingKata.Social.Users.UsersSupervisor do
  @moduledoc """
  The Supervisor of all the processes about the users of the
  """
  use Supervisor
  alias SocialNetworkingKata.ServicesNamesResolver
  alias SocialNetworkingKata.Social.Messages.VolatileMessagesRepository

  @spec child_spec(username: String.t()) :: Supervisor.child_spec()
  def child_spec(username: username) do
    %{
      id: ServicesNamesResolver.get_name(__MODULE__, username),
      start: {__MODULE__, :start_link, [[username: username]]},
      type: :supervisor
    }
  end

  @spec start_link(username: String.t()) ::
          {:ok, pid()} | {:error, {:already_started, pid()} | {:shutdown, term()} | term()}
  def start_link(username: username) do
    Supervisor.start_link(__MODULE__, [username: username],
      name: ServicesNamesResolver.get_name(__MODULE__, username)
    )
  end

  @impl true
  @spec init(keyword()) :: {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}}
  def init(username: username) do
    children = [{VolatileMessagesRepository, username: username}]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
