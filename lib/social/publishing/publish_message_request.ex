defmodule SocialNetworkingKata.Social.Publishing.PublishMessageRequest do
  @moduledoc """
  A struct representing the request to publish a message into an user timeline.
  """

  use Domo
  alias SocialNetworkingKata.Social.Publishing.Message

  @typedoc "A publish message request"
  typedstruct do
    field :username, String.t()
    field :message, Message.t()
  end
end
