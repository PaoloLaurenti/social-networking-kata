defmodule SocialNetworkingKata.Time.UTCClock do
  @moduledoc """
  The clock of the social network in UTC time zone
  """
  @behaviour SocialNetworkingKata.Time.Clock

  @spec get_current_datetime :: {:ok, DateTime.t()}
  def get_current_datetime do
    DateTime.now("Etc/UTC")
  end
end
