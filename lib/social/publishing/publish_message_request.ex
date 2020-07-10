defmodule SocialNetworkingKata.Social.Publishing.PublishMessageRequest do
  @moduledoc """
  A struct representing the request to publish a message into an user timeline.
  """

  use Domo
  alias SocialNetworkingKata.Social.Publishing.Message
  alias SocialNetworkingKata.Social.Users.User

  @typedoc "A publish message request"
  typedstruct do
    field :user, User.t()
    field :message, Message.t()
  end
end
