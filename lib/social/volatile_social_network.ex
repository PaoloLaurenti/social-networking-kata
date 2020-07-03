defmodule SocialNetworkingKata.Social.VolatileSocialNetwork do
  @moduledoc """
  The Social Network engine
  """
  alias SocialNetworkingKata.Social.Messages.Message
  alias SocialNetworkingKata.Social.Messages.PublishMessage
  alias SocialNetworkingKata.Social.Messages.Timeline
  alias SocialNetworkingKata.Social.SocialNetwork
  alias SocialNetworkingKata.Social.Users.GetTimeline
  alias SocialNetworkingKata.Social.Users.User

  @behaviour SocialNetwork

  @spec run(cmd :: SocialNetwork.commands()) :: :ok | {:ok, Timeline.t()}
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
