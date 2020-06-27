defmodule SocialNetworkingKata.VolatileSocialNetwork do
  @moduledoc """
  The Social Network engine
  """
  @behaviour SocialNetworkingKata.SocialNetwork

  alias SocialNetworkingKata.Message
  alias SocialNetworkingKata.Messages.GetTimelineCommand
  alias SocialNetworkingKata.Messages.PublishCommand
  alias SocialNetworkingKata.Timeline
  alias SocialNetworkingKata.User

  @spec run(cmd :: PublishCommand.t() | GetTimelineCommand.t()) ::
          :ok | {:ok, Timeline.t()}
  def run(%PublishCommand{} = _cmd) do
    :ok
  end

  def run(%GetTimelineCommand{} = _cmd) do
    {:ok,
     %Timeline{
       user: %User{name: ""},
       messages: [%Message{text: "", sent_at: DateTime.now!("Etc/UTC")}]
     }}
  end
end
