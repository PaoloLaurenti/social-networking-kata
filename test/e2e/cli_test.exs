defmodule SocialNetworkingKata.Test.E2e.CliTest do
  @moduledoc false
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "view user timeline" do
    timeline_output =
      capture_io("Alice -> I love the weather today\nAlice\nexit", fn ->
        SocialNetworkingKata.Cli.main(nil)
      end)

    assert timeline_output == "I love the weather today (1 minutes ago)"
  end
end
