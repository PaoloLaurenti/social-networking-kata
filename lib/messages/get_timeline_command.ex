defmodule SocialNetworkingKata.Messages.GetTimelineCommand do
  @moduledoc """
  A struct representing the command to use to retrieve an user timeline.
  """

  use Domo

  @typedoc "A timeline command"
  typedstruct do
    field :message, String.t()
  end
end
