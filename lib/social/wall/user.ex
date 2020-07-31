defmodule SocialNetworkingKata.Social.Wall.User do
  @moduledoc """
  A struct representing the user of wall.
  """

  use Domo

  @typedoc "A wall user"
  typedstruct do
    field :name, String.t()
  end
end
