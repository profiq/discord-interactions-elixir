defmodule DiscordInteractions.Plug.ValidateRequestTest do
  use ExUnit.Case, async: true
  use Mimic

  import Plug.Conn

  alias DiscordInteractions.Plug.ValidateRequest

  setup do
    Application.put_env(:discord_interactions, :public_key, "1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF")

    Mimic.copy(Ed25519)

    %{
      conn: Plug.Test.conn(:post, "/discord", ""),
      body: Jason.encode!(%{type: 1})
    }
  end

  describe "call/2" do
    test "passes validation with valid signature", %{conn: conn, body: body} do
      expect(Ed25519, :valid_signature?, fn _sig, _msg, _key -> true end)

      conn =
        conn
        |> assign(:raw_body, [body])
        |> put_req_header("x-signature-ed25519", "0123456789ABCDEF")
        |> put_req_header("x-signature-timestamp", "timestamp")
        |> ValidateRequest.call(%{})

      refute conn.halted
    end

    test "returns 401 when signature is invalid", %{conn: conn, body: body} do
      expect(Ed25519, :valid_signature?, fn _sig, _msg, _key -> false end)

      conn =
        conn
        |> assign(:raw_body, [body])
        |> put_req_header("x-signature-ed25519", "0123456789ABCDEF")
        |> put_req_header("x-signature-timestamp", "timestamp")

      assert %{
        status: 401,
        halted: true
      } = ValidateRequest.call(conn, %{})
    end

    test "returns 401 when signature header is missing", %{conn: conn, body: body} do
      reject(&Ed25519.valid_signature?/3)

      conn =
        conn
        |> assign(:raw_body, [body])
        |> put_req_header("x-signature-timestamp", "timestamp")

      assert %{
        status: 401,
        halted: true
      } = ValidateRequest.call(conn, %{})
    end

    test "returns 401 when timestamp header is missing", %{conn: conn, body: body} do
      reject(&Ed25519.valid_signature?/3)

      conn =
        conn
        |> assign(:raw_body, [body])
        |> put_req_header("x-signature-ed25519", "0123456789ABCDEF")

      assert %{
        status: 401,
        halted: true
      } = ValidateRequest.call(conn, %{})
    end

    test "returns 500 when public key is not configured", %{conn: conn, body: body} do
      # Temporarily remove the public key config
      Application.delete_env(:discord_interactions, :public_key)

      conn =
        conn
        |> assign(:raw_body, [body])
        |> put_req_header("x-signature-ed25519", "0123456789ABCDEF")
        |> put_req_header("x-signature-timestamp", "timestamp")

      assert %{
        status: 500,
        halted: true
      } = ValidateRequest.call(conn, %{})
    end

    test "returns 500 when raw body is missing", %{conn: conn} do
      conn =
        conn
        |> put_req_header("x-signature-ed25519", "0123456789ABCDEF")
        |> put_req_header("x-signature-timestamp", "timestamp")

      assert %{
        status: 500,
        halted: true
      } = ValidateRequest.call(conn, %{})
    end
  end
end
