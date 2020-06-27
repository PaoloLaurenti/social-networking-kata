defmodule SocialNetworkingKata.Clock do
  @moduledoc """
  The behaviour that defines the clock of the social network
  """

  @callback get_current_datetime :: DateTime.t()
end
