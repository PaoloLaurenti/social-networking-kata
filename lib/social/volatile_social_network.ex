defmodule SocialNetworkingKata.Social.VolatileSocialNetwork do
  @moduledoc """
  The Social Network implementation that does not persist anything
  """
  alias SocialNetworkingKata.Social.Following.FollowUserRequest
  alias SocialNetworkingKata.Social.Messages.Message
  alias SocialNetworkingKata.Social.Messages.VolatileMessagesRepository
  alias SocialNetworkingKata.Social.Publishing.PublishMessageRequest
  alias SocialNetworkingKata.Social.SocialNetwork
  alias SocialNetworkingKata.Social.SocialNetworkSupervisor
  alias SocialNetworkingKata.Social.Timeline.GetTimelineRequest
  alias SocialNetworkingKata.Social.Timeline.GetTimelineResponse
  alias SocialNetworkingKata.Social.Timeline.GetTimelineResponseUser
  alias SocialNetworkingKata.Social.Users.VolatileUsersRepository
  alias SocialNetworkingKata.Social.Wall
  alias SocialNetworkingKata.Social.Wall.Entry
  alias SocialNetworkingKata.Social.Wall.EntryUser
  alias SocialNetworkingKata.Social.Wall.GetWallRequest
  alias SocialNetworkingKata.Social.Wall.User, as: WallUser

  @behaviour SocialNetwork

  @spec publish_message(request :: PublishMessageRequest.t()) :: :ok
  def publish_message(%PublishMessageRequest{} = request) do
    publish_message(request, [])
  end

  @spec publish_message(PublishMessageRequest.t(), opts :: keyword()) :: :ok
  def publish_message(%PublishMessageRequest{username: username, message: message_text}, opts) do
    clock = Keyword.get(opts, :clock, SocialNetworkingKata.Time.UTCClock)
    {:ok, now} = clock.get_current_datetime()
    res = SocialNetworkSupervisor.start_user(username)

    case res do
      {:ok, _} ->
        message = Message.new!(text: message_text, sent_at: now)
        VolatileMessagesRepository.add_user_message(username, message)

      {:error, {:already_started, _}} ->
        message = Message.new!(text: message_text, sent_at: now)
        VolatileMessagesRepository.add_user_message(username, message)
    end
  end

  @spec get_timeline(GetTimelineRequest.t()) :: {:ok, GetTimelineResponse.t()}
  def get_timeline(%GetTimelineRequest{username: username}) do
    res = SocialNetworkSupervisor.start_user(username)
    user = GetTimelineResponseUser.new!(name: username)

    case res do
      {:ok, _} ->
        {:ok, messages} = VolatileMessagesRepository.get_user_messages(username)
        {:ok, GetTimelineResponse.new!(user: user, messages: messages)}

      {:error, {:already_started, _}} ->
        {:ok, messages} = VolatileMessagesRepository.get_user_messages(username)
        {:ok, GetTimelineResponse.new!(user: user, messages: messages)}
    end
  end

  @spec follow_user(request :: FollowUserRequest.t()) :: :ok
  def follow_user(%FollowUserRequest{followee: followeeUsername, follower: followerUsername}) do
    VolatileUsersRepository.upsert_user_followings(
      followeeUsername: followeeUsername,
      followerUsername: followerUsername
    )
  end

  @spec get_wall(request :: GetWallRequest.t()) :: {:ok, Wall.t()}
  def get_wall(%GetWallRequest{username: username}) do
    {:ok, user} = VolatileUsersRepository.get_user(username)

    followed_users_entries =
      user.followed_usernames
      |> Enum.flat_map(fn followed_username ->
        {:ok, messages} = VolatileMessagesRepository.get_user_messages(followed_username)

        Enum.map(messages, fn m ->
          entry_user = EntryUser.new!(name: followed_username)
          Entry.new!(user: entry_user, message: m)
        end)
      end)

    {:ok, messages} = VolatileMessagesRepository.get_user_messages(username)

    user_entries =
      Enum.map(messages, fn m ->
        entry_user = EntryUser.new!(name: username)
        Entry.new!(user: entry_user, message: m)
      end)

    entries =
      user_entries
      |> Enum.concat(followed_users_entries)
      |> Enum.sort_by(& &1.message.sent_at, {:asc, DateTime})

    wall_user = WallUser.new!(name: username)
    {:ok, Wall.new!(user: wall_user, entries: entries)}
  end
end
