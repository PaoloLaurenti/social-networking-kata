defmodule SocialNetworkingKata.Social.Messages.VolatileMessagesRepository do
  @moduledoc """
  The volatile repository of all the messages of the Social Network
  """
  defmodule State do
    @moduledoc false
    use Domo
    alias SocialNetworkingKata.Social.Messages.Message

    typedstruct do
      field :messages, [Message.t()]
    end
  end

  use GenServer
  alias SocialNetworkingKata.ServicesNamesResolver
  alias SocialNetworkingKata.Social.Messages.Message

  @typep requests :: {:add_user_message, Message.t()} | :get_messages
  @typep responses :: {:reply, :ok, State.t()} | {:reply, {:ok, [Message.t()]}, State.t()}

  @spec start_link(username: String.t()) ::
          :ignore | {:error, any} | {:ok, pid}
  def start_link(username: username) do
    GenServer.start_link(__MODULE__, [], name: server_name(username))
  end

  @spec add_user_message(username :: String.t(), message :: Message.t()) :: :ok
  def add_user_message(username, %Message{} = message) do
    GenServer.call(server_name(username), {:add_user_message, message})
  end

  @spec get_user_messages(username :: String.t()) :: {:ok, [Message.t()]}
  def get_user_messages(username) do
    GenServer.call(server_name(username), :get_messages)
  end

  @impl true
  @spec init([]) :: {:ok, State.t()}
  def init([]) do
    {:ok, State.new!(messages: [])}
  end

  @impl true
  @spec handle_call(requests(), from :: GenServer.from(), State.t()) :: responses()
  def handle_call(
        {:add_user_message, %Message{} = message},
        _from,
        %State{messages: messages} = state
      ) do
    new_state = State.put!(state, :messages, [message | messages])
    {:reply, :ok, new_state}
  end

  def handle_call(:get_messages, _from, %State{messages: messages} = state) do
    sorted_messages = Enum.sort_by(messages, fn m -> m.sent_at end, :asc)
    {:reply, {:ok, sorted_messages}, state}
  end

  defp server_name(id), do: ServicesNamesResolver.get_name(__MODULE__, id)
end
