defmodule SocialNetworkingKata.Social.SocialNetwork do
  @moduledoc """
  The behaviour that defines the social network interactions
  """
  alias SocialNetworkingKata.Social.Following.FollowUserRequest
  alias SocialNetworkingKata.Social.Publishing.PublishMessageRequest
  alias SocialNetworkingKata.Social.Timeline.GetTimelineRequest
  alias SocialNetworkingKata.Social.TimelineResponse
  alias SocialNetworkingKata.Social.Wall
  alias SocialNetworkingKata.Social.Wall.GetWallRequest

  @type requests ::
          PublishMessageRequest.t()
          | GetTimelineRequest.t()
          | FollowUserRequest.t()
          | GetWallRequest.t()

  @callback publish_message(request :: PublishMessageRequest.t()) :: :ok
  @callback publish_message(request :: PublishMessageRequest.t(), opts :: keyword()) :: :ok
  @callback get_timeline(request :: GetTimelineRequest.t()) :: {:ok, TimelineResponse.t()}
  @callback follow_user(request :: FollowUserRequest.t()) :: :ok
  @callback get_wall(request :: GetWallRequest.t()) :: {:ok, Wall.t()}
end
