defmodule SocialNetworkingKata.Social.Following.FollowUserRequest do
  @moduledoc """
  A struct representing the request to follow an user.
  """

  use Domo
  alias SocialNetworkingKata.Social.Users.User

  @typedoc "A follow user request"
  typedstruct do
    field :followee, User.t()
    field :follower, User.t()
  end
end
