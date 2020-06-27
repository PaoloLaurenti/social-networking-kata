defmodule SocialNetworkingKata.Messages.PublishCommand do
  @moduledoc """
  A struct representing the command to use to publish a message into an user timeline.
  """

  use Domo
  alias SocialNetworkingKata.Message
  alias SocialNetworkingKata.User

  @typedoc "A publish command"
  typedstruct do
    field :user, User.t()
    field :message, Message.t()
  end
end
