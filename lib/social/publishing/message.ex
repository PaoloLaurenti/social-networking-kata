defmodule SocialNetworkingKata.Social.Publishing.Message do
  @moduledoc """
  A struct representing a message thas is going to be publlished.
  """

  use Domo

  @typedoc "A message"
  typedstruct do
    field :text, String.t()
  end
end
