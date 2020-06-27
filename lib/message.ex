defmodule SocialNetworkingKata.Message do
  @moduledoc """
  A struct representing a message.
  """

  use Domo

  @typedoc "A message"
  typedstruct do
    field :text, String.t()
    field :sent_at, DateTime.t()
  end
end
