defmodule SocialNetworkingKata.Social.Wall.Entry do
  @moduledoc """
  A struct representing an entry of an user wall.
  """

  use Domo
  alias SocialNetworkingKata.Social.Messages.Message
  alias SocialNetworkingKata.Social.Wall.EntryUser

  @typedoc "An user wall"
  typedstruct do
    field :user, EntryUser.t()
    field :message, Message.t()
  end
end
