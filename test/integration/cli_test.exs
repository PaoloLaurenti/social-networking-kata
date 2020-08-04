defmodule SocialNetworkingKata.Test.Integration.CliTest do
  @moduledoc false
  use ExUnit.Case

  import ExUnit.CaptureIO
  import Mox

  alias SocialNetworkingKata.Social.Following.FollowUserRequest
  alias SocialNetworkingKata.Social.Messages.Message
  alias SocialNetworkingKata.Social.Publishing.PublishMessageRequest
  alias SocialNetworkingKata.Social.Timeline
  alias SocialNetworkingKata.Social.Timeline.GetTimelineRequest
  alias SocialNetworkingKata.Social.Users.User
  alias SocialNetworkingKata.Social.Wall
  alias SocialNetworkingKata.Social.Wall.Entry
  alias SocialNetworkingKata.Social.Wall.EntryUser
  alias SocialNetworkingKata.Social.Wall.GetWallRequest
  alias SocialNetworkingKata.Social.Wall.User, as: WallUser

  setup :set_mox_from_context

  test "CLI stops after exit command" do
    output =
      capture_io([input: "exit", capture_prompt: false], fn ->
        SocialNetworkingKata.Cli.main()
      end)

    assert output == "bye\n"
  end

  test "CLI publishes messages to the social network" do
    test_pid = self()

    stub(SocialNetworkServerMock, :publish_message, fn req ->
      send(test_pid, req)
      :ok
    end)

    capture_io(
      [input: "Alice -> I love the weather today\nexit", capture_prompt: false],
      fn ->
        SocialNetworkingKata.Cli.main(social_network: SocialNetworkServerMock)
      end
    )

    expected_publish_request =
      PublishMessageRequest.new!(
        username: "Alice",
        message: "I love the weather today"
      )

    assert_receive ^expected_publish_request
  end

  test "CLI gets user timeline from social network" do
    parent = self()
    ref = make_ref()
    now = DateTime.now!("Etc/UTC")
    four_minutes_and_something_ago = DateTime.add(now, -250, :second)
    less_than_one_minute_ago = DateTime.add(now, -45, :second)

    stub(ClockMock, :get_current_datetime, fn -> {:ok, now} end)

    stub(SocialNetworkServerMock, :get_timeline, fn req ->
      send(parent, {ref, req})

      {:ok,
       Timeline.new!(
         user: User.new!(name: "Alice"),
         messages: [
           Message.new!(text: "Some older message", sent_at: four_minutes_and_something_ago),
           Message.new!(text: "Some recent message", sent_at: less_than_one_minute_ago)
         ]
       )}
    end)

    output =
      capture_io(
        [input: "Alice\nexit", capture_prompt: false],
        fn ->
          SocialNetworkingKata.Cli.main(social_network: SocialNetworkServerMock, clock: ClockMock)
        end
      )

    expected_timeline_command = GetTimelineRequest.new!(username: "Alice")
    assert_receive {^ref, ^expected_timeline_command}

    assert output ==
             "Some recent message (45 seconds ago)\nSome older message (5 minutes ago)\nbye\n"
  end

  test "CLI reports timestamps of user timeline messages sent less than one minute ago, using seconds unit" do
    now = DateTime.now!("Etc/UTC")
    less_than_one_minute_ago = DateTime.add(now, -45, :second)
    one_second_ago = DateTime.add(now, -1, :second)

    test_timeline_messages_time_unit(
      [
        Message.new!(text: "Some older message", sent_at: less_than_one_minute_ago),
        Message.new!(text: "Some recent message", sent_at: one_second_ago)
      ],
      "Some recent message (1 second ago)\nSome older message (45 seconds ago)\nbye\n",
      now
    )
  end

  test "CLI reports timestamps user timeline messages sent less than one day ago, using hours unit" do
    now = DateTime.now!("Etc/UTC")
    eleven_hours_ago = DateTime.add(now, -39_600, :second)
    one_hour_ago = DateTime.add(now, -3600, :second)

    test_timeline_messages_time_unit(
      [
        Message.new!(text: "Some older message", sent_at: eleven_hours_ago),
        Message.new!(text: "Some recent message", sent_at: one_hour_ago)
      ],
      "Some recent message (1 hour ago)\nSome older message (11 hours ago)\nbye\n",
      now
    )
  end

  test "CLI reports timestamps user timeline messages sent less than more than or equal to one day ago, using days unit" do
    now = DateTime.now!("Etc/UTC")
    eleven_days_ago = DateTime.add(now, -950_400, :second)
    one_day_ago = DateTime.add(now, -86_400, :second)

    test_timeline_messages_time_unit(
      [
        Message.new!(text: "Some older message", sent_at: eleven_days_ago),
        Message.new!(text: "Some recent message", sent_at: one_day_ago)
      ],
      "Some recent message (1 day ago)\nSome older message (11 days ago)\nbye\n",
      now
    )
  end

  test "CLI sends follow command to the social network" do
    test_pid = self()

    stub(SocialNetworkServerMock, :follow_user, fn req ->
      send(test_pid, req)
      :ok
    end)

    capture_io(
      [input: "Charlie follows Alice\nexit", capture_prompt: false],
      fn ->
        SocialNetworkingKata.Cli.main(social_network: SocialNetworkServerMock)
      end
    )

    expected_follow_request = FollowUserRequest.new!(followee: "Alice", follower: "Charlie")
    assert_receive ^expected_follow_request
  end

  test "CLI gets user wall from social network" do
    parent = self()
    ref = make_ref()
    now = DateTime.now!("Etc/UTC")
    four_minutes_and_something_ago = DateTime.add(now, -250, :second)
    less_than_one_minute_ago = DateTime.add(now, -45, :second)

    stub(ClockMock, :get_current_datetime, fn -> {:ok, now} end)

    stub(SocialNetworkServerMock, :get_wall, fn req ->
      send(parent, {ref, req})

      charlie_wall =
        Wall.new!(
          user: WallUser.new!(name: "Charlie"),
          entries: [
            Entry.new!(
              user: EntryUser.new!(name: "Charlie"),
              message:
                Message.new!(text: "I'm in New York today!", sent_at: less_than_one_minute_ago)
            ),
            Entry.new!(
              user: EntryUser.new!(name: "Alice"),
              message:
                Message.new!(
                  text: "I love the weather today",
                  sent_at: four_minutes_and_something_ago
                )
            )
          ]
        )

      {:ok, charlie_wall}
    end)

    output =
      capture_io(
        [input: "Charlie wall\nexit", capture_prompt: false],
        fn ->
          SocialNetworkingKata.Cli.main(social_network: SocialNetworkServerMock, clock: ClockMock)
        end
      )

    expected_timeline_command = GetWallRequest.new!(username: "Charlie")
    assert_receive {^ref, ^expected_timeline_command}

    assert output ==
             "Charlie - I'm in New York today! (45 seconds ago)\nAlice - I love the weather today (5 minutes ago)\nbye\n"
  end

  def test_timeline_messages_time_unit(timeline_messages, expected_output, now) do
    stub(ClockMock, :get_current_datetime, fn -> {:ok, now} end)

    stub(SocialNetworkServerMock, :get_timeline, fn _req ->
      {:ok,
       Timeline.new!(
         user: User.new!(name: "Alice"),
         messages: timeline_messages
       )}
    end)

    output =
      capture_io(
        [input: "Alice\nexit", capture_prompt: false],
        fn ->
          SocialNetworkingKata.Cli.main(social_network: SocialNetworkServerMock, clock: ClockMock)
        end
      )

    assert output == expected_output
  end
end
