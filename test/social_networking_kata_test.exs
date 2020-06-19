defmodule SocialNetworkingKataTest do
  use ExUnit.Case
  doctest SocialNetworkingKata

  test "greets the world" do
    assert SocialNetworkingKata.hello() == :world
  end
end
