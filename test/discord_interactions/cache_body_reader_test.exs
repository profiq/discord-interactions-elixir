defmodule DiscordInteractions.CacheBodyReaderTest do
  use ExUnit.Case, async: true
  use Mimic

  import Plug.Conn

  alias DiscordInteractions.CacheBodyReader

  setup do
    Mimic.copy(Plug.Conn)
    %{conn: Plug.Test.conn(:post, "/test", "")}
  end

  describe "read_body/2" do
    test "reads body and caches it in assigns", %{conn: conn} do
      body = "test body content"

      expect(Plug.Conn, :read_body, fn ^conn, [] ->
        {:ok, body, conn}
      end)

      assert {:ok, ^body, updated_conn} = CacheBodyReader.read_body(conn, [])
      assert updated_conn.assigns[:raw_body] == [body]
    end

    test "appends to existing cached body", %{conn: conn} do
      existing_body = ["existing content"]
      new_body = "new content"

      conn = assign(conn, :raw_body, existing_body)

      expect(Plug.Conn, :read_body, fn ^conn, [] ->
        {:ok, new_body, conn}
      end)

      assert {:ok, ^new_body, updated_conn} = CacheBodyReader.read_body(conn, [])
      assert updated_conn.assigns[:raw_body] == [new_body, "existing content"]
    end

    test "handles empty existing raw_body", %{conn: conn} do
      body = "test body"

      expect(Plug.Conn, :read_body, fn ^conn, [] ->
        {:ok, body, conn}
      end)

      assert {:ok, ^body, updated_conn} = CacheBodyReader.read_body(conn, [])
      assert updated_conn.assigns[:raw_body] == [body]
    end

    test "passes through read_body options", %{conn: conn} do
      body = "test body"
      opts = [length: 1000, read_length: 100]

      expect(Plug.Conn, :read_body, fn ^conn, ^opts ->
        {:ok, body, conn}
      end)

      assert {:ok, ^body, updated_conn} = CacheBodyReader.read_body(conn, opts)
      assert updated_conn.assigns[:raw_body] == [body]
    end

    test "handles :more response from read_body", %{conn: conn} do
      body = "partial body"

      expect(Plug.Conn, :read_body, fn ^conn, [] ->
        {:more, body, conn}
      end)

      # The :more case is not handled by the with statement, so it passes through unchanged
      assert {:more, ^body, ^conn} = CacheBodyReader.read_body(conn, [])
    end

    test "handles error response from read_body", %{conn: conn} do
      error = :timeout

      expect(Plug.Conn, :read_body, fn ^conn, [] ->
        {:error, error}
      end)

      assert {:error, ^error} = CacheBodyReader.read_body(conn, [])
    end
  end
end
