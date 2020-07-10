defmodule SocialNetworkingKata.Social.Timeline.GetTimelineRequest do
  @moduledoc """
  A struct representing the request to retrieve an user timeline.
  """

  use Domo
  alias SocialNetworkingKata.Social.Users.User

  @typedoc "A retrieve timeline request"
  typedstruct do
    field :user, User.t()
  end
end
