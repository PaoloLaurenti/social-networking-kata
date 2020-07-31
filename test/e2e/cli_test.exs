defmodule SocialNetworkingKata.Test.E2e.CliTest do
  @moduledoc false
  use ExUnit.Case
  import ExUnit.CaptureIO

  setup do
    _ =
      start_supervised!(%{
        id: SocialNetworkingKata.Application,
        start: {SocialNetworkingKata.Application, :start, [nil, nil]}
      })

    :ok
  end

  test "view user timeline" do
    output =
      capture_io(
        [input: "Alice -> I love the weather today\nAlice\nexit", capture_prompt: false],
        fn ->
          SocialNetworkingKata.Cli.main()
        end
      )

    assert output =~ ~r/^\nI love the weather today \(\d+ seconds? ago\)\nbye\n$/
  end

  test "view user wall" do
    alice_message = "Alice -> I love the weather today"
    charlie_message = "Charlie -> I'm in New York today!"

    input = [
      alice_message,
      charlie_message,
      "Bob -> Damn! We lost!",
      "Charlie follows Alice",
      "Charlie wall",
      "exit"
    ]

    output =
      capture_io(
        [input: Enum.join(input, "\n"), capture_prompt: false],
        fn ->
          SocialNetworkingKata.Cli.main()
        end
      )

    pattern =
      "^\\n+Charlie - I\\'m in New York today! \\(\\d+ seconds? ago\\)\\nAlice - I love the weather today \\(\\d+ seconds? ago\\)\\nbye\\n$"
      |> Regex.compile!()

    assert output =~ pattern
  end
end
