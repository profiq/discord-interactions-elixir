defmodule DiscordInteractions.UtilTest do
  use ExUnit.Case, async: true
  doctest DiscordInteractions.Util

  alias DiscordInteractions.Util

  setup do
    %{conn: Plug.Test.conn(:post, "/test", "")}
  end

  describe "error/2" do
    test "sends error response with correct status code", %{conn: conn} do
      result = Util.error(conn, :bad_request)
      
      assert result.status == 400
      assert result.halted == true
      assert result.resp_body == "Bad Request"
    end

    test "handles unauthorized error", %{conn: conn} do
      result = Util.error(conn, :unauthorized)
      
      assert result.status == 401
      assert result.halted == true
      assert result.resp_body == "Unauthorized"
    end

    test "handles internal server error", %{conn: conn} do
      result = Util.error(conn, :internal_server_error)
      
      assert result.status == 500
      assert result.halted == true
      assert result.resp_body == "Internal Server Error"
    end

    test "handles method not allowed error", %{conn: conn} do
      result = Util.error(conn, :method_not_allowed)
      
      assert result.status == 405
      assert result.halted == true
      assert result.resp_body == "Method Not Allowed"
    end
  end

  describe "channel_type/1" do
    test "converts guild_text atom to integer" do
      assert Util.channel_type(:guild_text) == 0
    end

    test "converts dm atom to integer" do
      assert Util.channel_type(:dm) == 1
    end

    test "converts guild_voice atom to integer" do
      assert Util.channel_type(:guild_voice) == 2
    end

    test "converts group_dm atom to integer" do
      assert Util.channel_type(:group_dm) == 3
    end

    test "converts guild_category atom to integer" do
      assert Util.channel_type(:guild_category) == 4
    end

    test "converts guild_announcement atom to integer" do
      assert Util.channel_type(:guild_announcement) == 5
    end

    test "converts announcement_thread atom to integer" do
      assert Util.channel_type(:announcement_thread) == 10
    end

    test "converts public_thread atom to integer" do
      assert Util.channel_type(:public_thread) == 11
    end

    test "converts private_thread atom to integer" do
      assert Util.channel_type(:private_thread) == 12
    end

    test "converts guild_stage_voice atom to integer" do
      assert Util.channel_type(:guild_stage_voice) == 13
    end

    test "converts guild_directory atom to integer" do
      assert Util.channel_type(:guild_directory) == 14
    end

    test "converts guild_forum atom to integer" do
      assert Util.channel_type(:guild_forum) == 15
    end

    test "converts guild_media atom to integer" do
      assert Util.channel_type(:guild_media) == 16
    end

    test "passes through integer values" do
      assert Util.channel_type(0) == 0
      assert Util.channel_type(5) == 5
      assert Util.channel_type(99) == 99
    end

    test "raises error for invalid channel type" do
      assert_raise RuntimeError, "Invalid channel type: :invalid", fn ->
        Util.channel_type(:invalid)
      end
    end

    test "raises error for invalid string type" do
      assert_raise RuntimeError, "Invalid channel type: \"invalid\"", fn ->
        Util.channel_type("invalid")
      end
    end
  end

  describe "channel_types/1" do
    test "converts list of atoms to integers" do
      result = Util.channel_types([:guild_text, :guild_announcement])
      assert result == [0, 5]
    end

    test "converts mixed list of atoms and integers" do
      result = Util.channel_types([:guild_text, 5, :guild_voice])
      assert result == [0, 5, 2]
    end

    test "handles empty list" do
      result = Util.channel_types([])
      assert result == []
    end

    test "handles nil input" do
      result = Util.channel_types(nil)
      assert result == nil
    end

    test "converts list of integers" do
      result = Util.channel_types([0, 1, 2])
      assert result == [0, 1, 2]
    end
  end
end
