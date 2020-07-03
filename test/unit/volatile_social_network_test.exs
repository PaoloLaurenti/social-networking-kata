defmodule SocialNetworkingKata.Test.Unit.VolatileSocialNetworkTest do
  @moduledoc false
  use ExUnit.Case

  alias SocialNetworkingKata.Social.Messages.Message
  alias SocialNetworkingKata.Social.Messages.PublishMessage
  alias SocialNetworkingKata.Social.Users.User
  alias SocialNetworkingKata.Social.VolatileSocialNetwork

  test "publish message returns successfull result" do
    user = User.new!(name: "Alice")
    message = Message.new!(text: "Some message content", sent_at: DateTime.now!("Etc/UTC"))
    publish_message_cmd = PublishMessage.new!(user: user, message: message)
    result = VolatileSocialNetwork.run(publish_message_cmd)

    assert result === :ok
  end
end
