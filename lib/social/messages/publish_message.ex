defmodule SocialNetworkingKata.Social.Messages.PublishMessage do
  @moduledoc """
  A struct representing the command to use to publish a message into an user timeline.
  """

  use Domo
  alias SocialNetworkingKata.Social.Messages.Message
  alias SocialNetworkingKata.Social.Users.User

  @typedoc "A publish command"
  typedstruct do
    field :user, User.t()
    field :message, Message.t()
  end
end
