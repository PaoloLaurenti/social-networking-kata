defmodule SocialNetworkingKata.Test.Integration.CliTest do
  @moduledoc false
  use ExUnit.Case

  import ExUnit.CaptureIO
  import Mox

  alias SocialNetworkingKata.Message
  alias SocialNetworkingKata.Messages.GetTimelineCommand
  alias SocialNetworkingKata.Messages.PublishCommand
  alias SocialNetworkingKata.Timeline
  alias SocialNetworkingKata.User

  test "CLI stops after exit command" do
    output =
      capture_io([input: "exit", capture_prompt: false], fn ->
        SocialNetworkingKata.Cli.main()
      end)

    assert output == "bye\n"
  end

  test "CLI publishes messages to the social network" do
    publish_message_sent_at = DateTime.now!("Etc/UTC")
    test_pid = self()

    stub(SocialNetworkServerMock, :run, fn cmd ->
      send(test_pid, cmd)
      :ok
    end)

    stub(ClockMock, :get_current_datetime, fn -> publish_message_sent_at end)

    capture_io(
      [input: "Alice -> I love the weather today\nexit", capture_prompt: false],
      fn ->
        SocialNetworkingKata.Cli.main(social_network: SocialNetworkServerMock, clock: ClockMock)
      end
    )

    expected_publish_command =
      PublishCommand.new!(
        user: User.new!(name: "Alice"),
        message: Message.new!(text: "I love the weather today", sent_at: publish_message_sent_at)
      )

    assert_receive ^expected_publish_command
  end

  test "CLI gets user timeline from social network" do
    # defmock(SocialNetworkServerMock, for: SocialNetwork)
    now = DateTime.now!("Etc/UTC")
    four_minutes_and_something_ago = DateTime.add(now, -250, :second)
    less_than_one_minute_ago = DateTime.add(now, -45, :second)

    stub(SocialNetworkServerMock, :run, fn cmd ->
      send(self(), cmd)

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
          SocialNetworkingKata.Cli.main(social_network: SocialNetworkServerMock)
        end
      )

    expected_timeline_command = GetTimelineCommand.new!(user: User.new!(name: "Alice"))
    assert_receive ^expected_timeline_command

    assert output ==
             "Some recent message (1 minute ago)\nSome older message (5 minutes ago)\nbye\n"
  end
end
