defmodule SocialNetworkingKata.Social.TimelineResponse do
  @moduledoc """
  A struct representing an user timeline.
  """

  use Domo
  alias SocialNetworkingKata.Social.Messages.Message
  alias SocialNetworkingKata.Social.Users.User

  @typedoc "An user timeline"
  typedstruct do
    field :user, User.t()
    field :messages, [Message.t()]
  end
end
