defmodule SocialNetworkingKata.Social.Users.VolatileUsersRepository do
  @moduledoc """
  The volatile repository of all the users of the Social Network
  """
  alias SocialNetworkingKata.Social.Users.UserEntity

  defmodule State do
    @moduledoc false
    use Domo

    typedstruct do
      field :users, %{optional(String.t()) => UserEntity.t()}
    end
  end

  use GenServer

  @spec start_link([]) :: :ignore | {:error, any} | {:ok, pid}
  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec get_user(username :: String.t()) :: {:ok, UserEntity.t()}
  def get_user(username) do
    GenServer.call(__MODULE__, {:get_user, username})
  end

  @spec upsert_user_followings(followeeUsername: String.t(), followerUsername: String.t()) :: :ok
  def upsert_user_followings(
        followeeUsername: followeeUsername,
        followerUsername: followerUsername
      ) do
    GenServer.call(__MODULE__, {:upsert_user_followings, followeeUsername, followerUsername})
  end

  @impl true
  @spec init([]) :: {:ok, State.t()}
  def init([]) do
    {:ok, State.new!(users: %{})}
  end

  @impl true
  @spec handle_call({:get_user, String.t()}, from :: GenServer.from(), State.t()) ::
          {:reply, {:ok, UserEntity.t()}, State.t()}
  def handle_call({:get_user, username}, _from, %State{users: users} = state) do
    user = users[username]
    {:reply, {:ok, user}, state}
  end

  @impl true
  @spec handle_call(
          {:upsert_user_followings, String.t(), String.t()},
          from :: GenServer.from(),
          State.t()
        ) ::
          {:reply, :ok, State.t()}
  def handle_call(
        {:upsert_user_followings, followeeUsername, followerUsername},
        _from,
        %State{users: users} = state
      ) do
    user =
      users[followerUsername] || UserEntity.new!(name: followerUsername, followed_usernames: [])

    updated_user = %UserEntity{
      user
      | followed_usernames: [followeeUsername | user.followed_usernames]
    }

    updated_state = %State{state | users: Map.put(users, followerUsername, updated_user)}
    {:reply, :ok, updated_state}
  end
end
