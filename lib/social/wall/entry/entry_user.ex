defmodule SocialNetworkingKata.Social.Wall.Entry.User do
  @moduledoc """
  A struct representing an user of a wall entry.
  """

  use Domo

  @typedoc "A wall entry user"
  typedstruct do
    field :username, String.t()
  end
end
