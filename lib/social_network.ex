defmodule SocialNetworkingKata.SocialNetwork do
  @moduledoc """
  The behaviour that defines the social network interactions
  """
  alias SocialNetworkingKata.Messages.GetTimelineCommand
  alias SocialNetworkingKata.Messages.PublishCommand
  alias SocialNetworkingKata.Timeline

  @callback run(cmd :: PublishCommand.t()) :: :ok
  @callback run(cmd :: GetTimelineCommand.t()) :: {:ok, Timeline.t()}
end
