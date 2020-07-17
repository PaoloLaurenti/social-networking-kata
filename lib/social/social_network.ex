defmodule SocialNetworkingKata.Social.SocialNetwork do
  @moduledoc """
  The behaviour that defines the social network interactions
  """
  alias SocialNetworkingKata.Social.Following.FollowUserRequest
  alias SocialNetworkingKata.Social.Publishing.PublishMessageRequest
  alias SocialNetworkingKata.Social.Timeline
  alias SocialNetworkingKata.Social.Timeline.GetTimelineRequest

  @type requests :: PublishMessageRequest.t() | GetTimelineRequest.t() | FollowUserRequest.t()

  @callback publish_message(request :: PublishMessageRequest.t()) :: :ok
  @callback publish_message(request :: PublishMessageRequest.t(), opts :: keyword()) :: :ok
  @callback get_timeline(request :: GetTimelineRequest.t()) :: {:ok, Timeline.t()}
  @callback follow_user(request :: FollowUserRequest.t()) :: :ok
end
