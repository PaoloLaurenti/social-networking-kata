defmodule SocialNetworkingKata.Social.VolatileSocialNetwork do
  @moduledoc """
  The Social Network implementation that does not persist anything
  """
  alias SocialNetworkingKata.Social.Following.FollowUserRequest
  alias SocialNetworkingKata.Social.Messages.Message
  alias SocialNetworkingKata.Social.Messages.VolatileMessagesRepository
  alias SocialNetworkingKata.Social.Publishing.Message, as: MessageToPublish
  alias SocialNetworkingKata.Social.Publishing.PublishMessageRequest
  alias SocialNetworkingKata.Social.SocialNetwork
  alias SocialNetworkingKata.Social.SocialNetworkSupervisor
  alias SocialNetworkingKata.Social.Timeline
  alias SocialNetworkingKata.Social.Timeline.GetTimelineRequest

  @behaviour SocialNetwork

  @spec publish_message(request :: PublishMessageRequest.t()) :: :ok
  def publish_message(%PublishMessageRequest{} = request) do
    publish_message(request, [])
  end

  @spec publish_message(PublishMessageRequest.t(), opts :: keyword()) :: :ok
  def publish_message(
        %PublishMessageRequest{user: user, message: %MessageToPublish{text: message_text}},
        opts
      ) do
    clock = Keyword.get(opts, :clock, SocialNetworkingKata.Time.UTCClock)
    {:ok, now} = clock.get_current_datetime()
    res = SocialNetworkSupervisor.start_user(user)

    case res do
      {:ok, _} ->
        message = Message.new!(text: message_text, sent_at: now)
        VolatileMessagesRepository.add_user_message(user, message)

      {:error, {:already_started, _}} ->
        message = Message.new!(text: message_text, sent_at: now)
        VolatileMessagesRepository.add_user_message(user, message)
    end
  end

  @spec get_timeline(GetTimelineRequest.t()) :: {:ok, Timeline.t()}
  def get_timeline(%GetTimelineRequest{user: user}) do
    res = SocialNetworkSupervisor.start_user(user)

    case res do
      {:ok, _} ->
        {:ok, messages} = VolatileMessagesRepository.get_user_messages(user)
        {:ok, %Timeline{user: user, messages: messages}}

      {:error, {:already_started, _}} ->
        {:ok, messages} = VolatileMessagesRepository.get_user_messages(user)
        {:ok, %Timeline{user: user, messages: messages}}
    end
  end

  @spec follow_user(request :: FollowUserRequest.t()) :: :ok
  def follow_user(_request) do
    :ok
  end
end
