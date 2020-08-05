defmodule SocialNetworkingKata.Social.Timeline.GetTimelineResponse do
  @moduledoc """
  A struct representing an user timeline.
  """

  use Domo
  alias SocialNetworkingKata.Social.Messages.Message
  alias SocialNetworkingKata.Social.Timeline.GetTimelineResponseUser

  @typedoc "An user timeline"
  typedstruct do
    field :user, GetTimelineResponseUser.t()
    field :messages, [Message.t()]
  end
end
