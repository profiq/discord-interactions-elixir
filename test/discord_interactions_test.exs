defmodule DiscordInteractionsTest do
  use ExUnit.Case
  doctest DiscordInteractions

  test "greets the world" do
    assert DiscordInteractions.hello() == :world
  end
end
