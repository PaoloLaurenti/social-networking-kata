defmodule SocialNetworkingKata.Social.Timeline.GetTimelineRequest do
  @moduledoc """
  A struct representing the request to retrieve an user timeline.
  """

  use Domo

  @typedoc "A retrieve timeline request"
  typedstruct do
    field :username, String.t()
  end
end
