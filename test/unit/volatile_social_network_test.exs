defmodule SocialNetworkingKata.Test.Unit.VolatileSocialNetworkTest do
  @moduledoc false
  use ExUnit.Case

  import Mox

  alias SocialNetworkingKata.Social.Following.FollowUserRequest
  alias SocialNetworkingKata.Social.Messages.Message
  alias SocialNetworkingKata.Social.Publishing.Message, as: MessageToPublish
  alias SocialNetworkingKata.Social.Publishing.PublishMessageRequest
  alias SocialNetworkingKata.Social.Timeline
  alias SocialNetworkingKata.Social.Timeline.GetTimelineRequest
  alias SocialNetworkingKata.Social.Users.User
  alias SocialNetworkingKata.Social.VolatileSocialNetwork

  setup :set_mox_from_context

  setup do
    _ =
      start_supervised!(%{
        id: SocialNetworkingKata.Application,
        start: {SocialNetworkingKata.Application, :start, [nil, nil]}
      })

    :ok
  end

  test "publish message returns successfull result" do
    user = User.new!(name: "Alice")
    message = MessageToPublish.new!(text: "Some message content")
    publish_message_req = PublishMessageRequest.new!(user: user, message: message)
    result = VolatileSocialNetwork.publish_message(publish_message_req)

    assert result === :ok
  end

  test "get timeline of an unknown user returns an empty timeline" do
    user = User.new!(name: "Alice")

    result = GetTimelineRequest.new!(user: user) |> VolatileSocialNetwork.get_timeline()

    expected_result = {:ok, Timeline.new!(user: user, messages: [])}
    assert result === expected_result
  end

  test "get timeline returns the messages published by an user before" do
    now = DateTime.now!("Etc/UTC")
    four_minutes_and_something_ago = DateTime.add(now, -250, :second)
    less_than_one_minute_ago = DateTime.add(now, -45, :second)
    user = User.new!(name: "Alice")
    stub(ClockMock, :get_current_datetime, fn -> {:ok, four_minutes_and_something_ago} end)

    :ok =
      PublishMessageRequest.new!(
        user: user,
        message: MessageToPublish.new!(text: "Some message content")
      )
      |> VolatileSocialNetwork.publish_message(clock: ClockMock)

    stub(ClockMock, :get_current_datetime, fn -> {:ok, less_than_one_minute_ago} end)

    :ok =
      PublishMessageRequest.new!(
        user: user,
        message: MessageToPublish.new!(text: "Some other message content")
      )
      |> VolatileSocialNetwork.publish_message(clock: ClockMock)

    result = GetTimelineRequest.new!(user: user) |> VolatileSocialNetwork.get_timeline()

    expected_result =
      {:ok,
       Timeline.new!(
         user: user,
         messages: [
           Message.new!(text: "Some message content", sent_at: four_minutes_and_something_ago),
           Message.new!(text: "Some other message content", sent_at: less_than_one_minute_ago)
         ]
       )}

    assert result === expected_result
  end

  test "follow user returns successfull result" do
    followee_user = User.new!(name: "Alice")
    follower_user = User.new!(name: "Charlie")

    result =
      FollowUserRequest.new!(followee: followee_user, follower: follower_user)
      |> VolatileSocialNetwork.follow_user()

    assert result === :ok
  end
end
