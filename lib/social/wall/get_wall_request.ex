defmodule SocialNetworkingKata.Social.Wall.GetWallRequest do
  @moduledoc """
  A struct representing the request to retrieve an user wall.
  """

  use Domo

  @typedoc "A retrieve wall request"
  typedstruct do
    field :username, String.t()
  end
end
