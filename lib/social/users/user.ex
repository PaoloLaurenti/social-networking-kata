defmodule SocialNetworkingKata.Social.Users.User do
  @moduledoc """
  A struct representing an user.
  """

  use Domo

  @typedoc "An user"
  typedstruct do
    field :name, String.t()
  end
end
