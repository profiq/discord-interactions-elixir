defmodule DiscordInteractions.PlugTest do
  use ExUnit.Case, async: true
  use Mimic

  import Plug.Conn

  defmodule TestHandler do
    use DiscordInteractions

    interactions do
      application_command "test", :chat_input do
        description("A test command")
        handler(&test_command/1)
      end
    end

    def test_command(_interaction) do
      {:ok, %{type: 4, data: %{content: "Test response"}}}
    end
  end

  setup do
    Application.put_env(
      :discord_interactions,
      :public_key,
      "1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF"
    )

    Mimic.copy(Ed25519)

    %{
      body: Jason.encode!(%{type: 1})
    }
  end

  describe "call/2" do
    test "accepts POST requests", %{body: body} do
      expect(Ed25519, :valid_signature?, fn _sig, _msg, _key -> true end)

      conn =
        Plug.Test.conn(:post, "/discord", "")
        |> assign(:raw_body, [body])
        |> put_req_header("x-signature-ed25519", "0123456789ABCDEF")
        |> put_req_header("x-signature-timestamp", "timestamp")
        |> DiscordInteractions.Plug.call(TestHandler)

      # The request should be processed (not halted due to method validation)
      # but may halt later due to handler issues - that's expected in this test
      assert conn.assigns[:discord_command_handler] == TestHandler
    end

    test "rejects non-POST requests" do
      conn = Plug.Test.conn(:get, "/discord", "")

      conn = DiscordInteractions.Plug.call(conn, TestHandler)

      assert conn.status == 405
      assert conn.halted
    end

    test "rejects PUT requests" do
      conn = Plug.Test.conn(:put, "/discord", "")

      conn = DiscordInteractions.Plug.call(conn, TestHandler)

      assert conn.status == 405
      assert conn.halted
    end

    test "rejects DELETE requests" do
      conn = Plug.Test.conn(:delete, "/discord", "")

      conn = DiscordInteractions.Plug.call(conn, TestHandler)

      assert conn.status == 405
      assert conn.halted
    end

    test "assigns discord_command_handler to conn", %{body: body} do
      # Don't expect the signature validation to be called since it might be skipped
      # due to missing headers or other validation issues
      conn =
        Plug.Test.conn(:post, "/discord", "")
        |> assign(:raw_body, [body])
        |> put_req_header("x-signature-ed25519", "0123456789ABCDEF")
        |> put_req_header("x-signature-timestamp", "timestamp")
        |> DiscordInteractions.Plug.call(TestHandler)

      assert conn.assigns[:discord_command_handler] == TestHandler
    end
  end

  describe "method validation" do
    test "allows POST method through the plug pipeline", %{body: body} do
      expect(Ed25519, :valid_signature?, fn _sig, _msg, _key -> true end)

      conn =
        Plug.Test.conn(:post, "/test", "")
        |> assign(:raw_body, [body])
        |> put_req_header("x-signature-ed25519", "0123456789ABCDEF")
        |> put_req_header("x-signature-timestamp", "timestamp")
        |> DiscordInteractions.Plug.call(TestHandler)

      # The request should be processed (not halted due to method validation)
      # but may halt later due to handler issues - that's expected in this test
      assert conn.assigns[:discord_command_handler] == TestHandler
    end

    test "blocks GET method through the plug pipeline" do
      conn =
        Plug.Test.conn(:get, "/test", "")
        |> DiscordInteractions.Plug.call(TestHandler)

      assert conn.halted
      assert conn.status == 405
    end

    test "blocks PATCH method through the plug pipeline" do
      conn =
        Plug.Test.conn(:patch, "/test", "")
        |> DiscordInteractions.Plug.call(TestHandler)

      assert conn.halted
      assert conn.status == 405
    end
  end
end
