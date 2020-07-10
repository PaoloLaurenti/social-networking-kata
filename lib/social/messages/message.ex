defmodule SocialNetworkingKata.Social.Messages.Message do
  @moduledoc """
  A struct representing a message published by an user
  """

  use Domo

  @typedoc "A message"
  typedstruct do
    field :text, String.t()
    field :sent_at, DateTime.t()
  end
end
