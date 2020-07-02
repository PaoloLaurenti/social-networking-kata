defmodule SocialNetworkingKata.Social.VolatileSocialNetwork do
  @moduledoc """
  The Social Network engine
  """
  @behaviour SocialNetworkingKata.Social.SocialNetwork

  alias SocialNetworkingKata.Social.Messages.Message
  alias SocialNetworkingKata.Social.Messages.PublishMessage
  alias SocialNetworkingKata.Social.Messages.Timeline
  alias SocialNetworkingKata.Social.Users.User
  alias SocialNetworkingKata.Social.Users.Users.GetTimeline

  @spec run(cmd :: PublishMessage.t() | GetTimeline.t()) ::
          :ok | {:ok, Timeline.t()}
  def run(%PublishMessage{} = _cmd) do
    :ok
  end

  def run(%GetTimeline{} = _cmd) do
    {:ok,
     %Timeline{
       user: %User{name: ""},
       messages: [%Message{text: "", sent_at: DateTime.now!("Etc/UTC")}]
     }}
  end
end
