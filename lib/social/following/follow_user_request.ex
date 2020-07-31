defmodule SocialNetworkingKata.Social.Following.FollowUserRequest do
  @moduledoc """
  A struct representing the request to follow an user.
  """

  use Domo

  @typedoc "A follow user request"
  typedstruct do
    field :followee, String.t()
    field :follower, String.t()
  end
end
