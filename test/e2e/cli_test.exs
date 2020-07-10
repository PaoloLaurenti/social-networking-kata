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
    timeline_output =
      capture_io(
        [input: "Alice -> I love the weather today\nAlice\nexit", capture_prompt: false],
        fn ->
          SocialNetworkingKata.Cli.main()
        end
      )


    assert timeline_output =~ ~r/^\nI love the weather today \(\d+ seconds? ago\)\nbye\n$/
  end
end
