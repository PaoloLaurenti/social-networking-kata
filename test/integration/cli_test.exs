defmodule SocialNetworkingKata.Test.Integration.CliTest do
  @moduledoc false
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO
  import Mox

  alias SocialNetworkingKata.Clock
  alias SocialNetworkingKata.Message
  alias SocialNetworkingKata.Messages.PublishCommand
  alias SocialNetworkingKata.SocialNetwork
  alias SocialNetworkingKata.User

  setup :verify_on_exit!

  test "CLI stops after exit command" do
    output =
      capture_io([input: "exit", capture_prompt: false], fn ->
        SocialNetworkingKata.Cli.main()
      end)

    assert output == "bye\n"
  end

  test "CLI continues to run after unrecognized message" do
    output =
      capture_io([input: "dsfasdgsg\nexit", capture_prompt: false], fn ->
        SocialNetworkingKata.Cli.main()
      end)

    assert output == "sorry \"dsfasdgsg\" is an unknown command\nbye\n"
  end

  test "CLI publishes messages to the social network" do
    defmock(SocialNetworkServerMock, for: SocialNetwork)
    defmock(ClockMock, for: Clock)
    publish_message_sent_at = DateTime.now!("Etc/UTC")

    stub(SocialNetworkServerMock, :run, fn cmd ->
      send(self(), cmd)
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
end
