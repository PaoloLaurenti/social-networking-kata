defmodule SocialNetworkingKata.Social.Wall do
  @moduledoc """
  A struct representing an user wall.
  """

  use Domo
  alias SocialNetworkingKata.Social.Wall.Entry
  alias SocialNetworkingKata.Social.Wall.User

  @typedoc "An user wall"
  typedstruct do
    field :user, User.t()
    field :entries, [Entry.t()]
  end
end
