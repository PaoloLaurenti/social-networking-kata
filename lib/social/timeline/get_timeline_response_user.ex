defmodule SocialNetworkingKata.Social.Timeline.GetGetTimelineResponseUser do
  @moduledoc """
  A struct representing an user of a get timeline response.
  """

  use Domo

  @typedoc "A get timeline response user"
  typedstruct do
    field :name, String.t()
  end
end
