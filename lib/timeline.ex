defmodule SocialNetworkingKata.Timeline do
  @moduledoc """
  A struct representing an user timeline.
  """

  use Domo
  alias SocialNetworkingKata.Message
  alias SocialNetworkingKata.User

  @typedoc "An user timeline"
  typedstruct do
    field :user, User.t()
    field :messages, [Message.t()]
  end
end
