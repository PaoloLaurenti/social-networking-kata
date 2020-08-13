defmodule SocialNetworkingKata.Social.Wall.EntryUser do
  @moduledoc """
  A struct representing an user of a wall entry.
  """

  use Domo

  @typedoc "A wall entry user"
  typedstruct do
    field :username, String.t()
  end
end
