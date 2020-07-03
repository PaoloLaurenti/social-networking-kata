defmodule SocialNetworkingKata.Social.VolatileSocialNetwork do
  @moduledoc """
  The Social Network engine
  """
  alias SocialNetworkingKata.Social.Messages.PublishMessage
  alias SocialNetworkingKata.Social.Messages.Timeline
  alias SocialNetworkingKata.Social.SocialNetwork
  alias SocialNetworkingKata.Social.Users.GetTimeline

  @behaviour SocialNetwork

  @spec run(cmd :: SocialNetwork.commands()) :: :ok | {:ok, Timeline.t()}
  def run(%PublishMessage{} = _cmd) do
    :ok
  end

  def run(%GetTimeline{user: user} = _cmd) do
    {:ok, %Timeline{user: user, messages: []}}
  end
end
