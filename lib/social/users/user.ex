defmodule SocialNetworkingKata.Social.Users.User do
  @moduledoc """
  A struct representing an user of the Social Network.
  """

  use Domo

  @typedoc "An user"
  typedstruct do
    field :name, String.t()
    field :followed_usernames, [String.t()]
  end
end
