defmodule SocialNetworkingKata.Test.Integration.CliTest do
  @moduledoc false
  use ExUnit.Case

  import ExUnit.CaptureIO
  import Mox

  alias SocialNetworkingKata.Social.Messages.Message
  alias SocialNetworkingKata.Social.Publishing.Message, as: MessageToPublish
  alias SocialNetworkingKata.Social.Publishing.PublishMessageRequest
  alias SocialNetworkingKata.Social.Timeline
  alias SocialNetworkingKata.Social.Timeline.GetTimelineRequest
  alias SocialNetworkingKata.Social.Users.User

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
        user: User.new!(name: "Alice"),
        message: MessageToPublish.new!(text: "I love the weather today")
      )

    assert_receive ^expected_publish_request
  end

  test "CLI gets user timeline from social network" do
    now = DateTime.now!("Etc/UTC")
    four_minutes_and_something_ago = DateTime.add(now, -250, :second)
    less_than_one_minute_ago = DateTime.add(now, -45, :second)

    stub(SocialNetworkServerMock, :get_timeline, fn req ->
      send(self(), req)

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

    expected_timeline_command = GetTimelineRequest.new!(user: User.new!(name: "Alice"))
    assert_receive ^expected_timeline_command

    assert output ==
             "Some recent message (1 minute ago)\nSome older message (5 minutes ago)\nbye\n"
  end
end
