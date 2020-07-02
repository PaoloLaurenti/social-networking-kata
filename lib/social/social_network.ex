defmodule SocialNetworkingKata.Social.SocialNetwork do
  @moduledoc """
  The behaviour that defines the social network interactions
  """
  alias SocialNetworkingKata.Social.Messages.PublishMessage
  alias SocialNetworkingKata.Social.Messages.Timeline
  alias SocialNetworkingKata.Social.Users.Users.GetTimeline

  @type commands :: PublishMessage.t() | GetTimeline.t()

  @callback run(cmd :: PublishMessage.t()) :: :ok
  @callback run(cmd :: GetTimeline.t()) :: {:ok, Timeline.t()}
end
