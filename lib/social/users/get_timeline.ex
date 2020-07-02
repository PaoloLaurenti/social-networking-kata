defmodule SocialNetworkingKata.Social.Users.Users.GetTimeline do
  @moduledoc """
  A struct representing the command to use to retrieve an user timeline.
  """

  use Domo
  alias SocialNetworkingKata.Social.Users.User

  @typedoc "A timeline command"
  typedstruct do
    field :user, User.t()
  end
end
