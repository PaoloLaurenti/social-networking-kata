defmodule SocialNetworkingKata.Test.Unit.VolatileSocialNetworkTest do
  @moduledoc false
  use ExUnit.Case

  import Mox

  alias SocialNetworkingKata.Social.Following.FollowUserRequest
  alias SocialNetworkingKata.Social.Messages.Message
  alias SocialNetworkingKata.Social.Publishing.PublishMessageRequest
  alias SocialNetworkingKata.Social.Timeline.GetTimelineRequest
  alias SocialNetworkingKata.Social.TimelineResponse
  alias SocialNetworkingKata.Social.Users.User
  alias SocialNetworkingKata.Social.VolatileSocialNetwork
  alias SocialNetworkingKata.Social.Wall
  alias SocialNetworkingKata.Social.Wall.Entry
  alias SocialNetworkingKata.Social.Wall.EntryUser
  alias SocialNetworkingKata.Social.Wall.GetWallRequest
  alias SocialNetworkingKata.Social.Wall.User, as: WallUser

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
    publish_message_req =
      PublishMessageRequest.new!(username: "Alice", message: "Some message content")

    result = VolatileSocialNetwork.publish_message(publish_message_req)

    assert result === :ok
  end

  test "get timeline of an unknown user returns an empty timeline" do
    result = GetTimelineRequest.new!(username: "Alice") |> VolatileSocialNetwork.get_timeline()
    expected_result = {:ok, TimelineResponse.new!(user: User.new!(name: "Alice"), messages: [])}
    assert result === expected_result
  end

  test "get timeline returns the messages published before by an user" do
    now = DateTime.now!("Etc/UTC")
    four_minutes_and_something_ago = DateTime.add(now, -250, :second)
    less_than_one_minute_ago = DateTime.add(now, -45, :second)
    stub(ClockMock, :get_current_datetime, fn -> {:ok, four_minutes_and_something_ago} end)

    :ok =
      PublishMessageRequest.new!(username: "Alice", message: "Some message content")
      |> VolatileSocialNetwork.publish_message(clock: ClockMock)

    stub(ClockMock, :get_current_datetime, fn -> {:ok, less_than_one_minute_ago} end)

    :ok =
      PublishMessageRequest.new!(username: "Alice", message: "Some other message content")
      |> VolatileSocialNetwork.publish_message(clock: ClockMock)

    result = GetTimelineRequest.new!(username: "Alice") |> VolatileSocialNetwork.get_timeline()

    expected_result =
      {:ok,
       TimelineResponse.new!(
         user: User.new!(name: "Alice"),
         messages: [
           Message.new!(text: "Some message content", sent_at: four_minutes_and_something_ago),
           Message.new!(text: "Some other message content", sent_at: less_than_one_minute_ago)
         ]
       )}

    assert result === expected_result
  end

  test "follow user returns a successfull result" do
    result =
      FollowUserRequest.new!(followee: "Alice", follower: "Charlie")
      |> VolatileSocialNetwork.follow_user()

    assert result === :ok
  end

  @tag :skip
  test "follow user of an already follwed user returns a successfull result" do
  end

  test "get wall returns the user own messages and the messages published before by the followed users" do
    now = DateTime.now!("Etc/UTC")
    four_minutes_and_something_ago = DateTime.add(now, -250, :second)
    less_than_one_minute_ago = DateTime.add(now, -45, :second)
    stub(ClockMock, :get_current_datetime, fn -> {:ok, four_minutes_and_something_ago} end)

    :ok =
      PublishMessageRequest.new!(username: "Alice", message: "I love the weather today")
      |> VolatileSocialNetwork.publish_message(clock: ClockMock)

    stub(ClockMock, :get_current_datetime, fn -> {:ok, less_than_one_minute_ago} end)

    :ok =
      PublishMessageRequest.new!(username: "Charlie", message: "I'm in New York today!")
      |> VolatileSocialNetwork.publish_message(clock: ClockMock)

    FollowUserRequest.new!(followee: "Alice", follower: "Charlie")
    |> VolatileSocialNetwork.follow_user()

    {:ok, charlie_wall_result} =
      GetWallRequest.new!(username: "Charlie") |> VolatileSocialNetwork.get_wall()

    expected_charlie_wall_result =
      Wall.new!(
        user: WallUser.new!(name: "Charlie"),
        entries: [
          Entry.new!(
            user: EntryUser.new!(name: "Alice"),
            message:
              Message.new!(
                text: "I love the weather today",
                sent_at: four_minutes_and_something_ago
              )
          ),
          Entry.new!(
            user: EntryUser.new!(name: "Charlie"),
            message:
              Message.new!(text: "I'm in New York today!", sent_at: less_than_one_minute_ago)
          )
        ]
      )

    assert charlie_wall_result === expected_charlie_wall_result
  end

  @tag :skip
  test "get wall of an unknown user returns an empty wall" do
  end
end
