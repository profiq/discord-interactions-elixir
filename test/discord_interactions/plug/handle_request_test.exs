defmodule DiscordInteractions.Plug.HandleRequestTest do
  use ExUnit.Case, async: true
  use Mimic

  import Plug.Conn

  alias DiscordInteractions.Plug.HandleRequest

  setup do
    %{
      conn: Plug.Test.conn(:post, "/discord", "")
    }
  end

  describe "call/2" do
    test "handles ping interactions", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> assign(:discord_command_handler, nil)
        |> Map.put(:body_params, %{"type" => 1})
        |> HandleRequest.call(%{})

      assert conn.status == 200
      assert conn.halted
      assert conn.resp_body =~ ~s("type":1)
    end

    test "handles successful command responses", %{conn: conn} do
      # Define handler for this specific test
      defmodule SuccessHandler do
        alias DiscordInteractions.InteractionResponse

        def handle(_interaction),
          do:
            {:ok,
             InteractionResponse.channel_message_with_source()
             |> InteractionResponse.content("Success")}
      end

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> assign(:discord_command_handler, SuccessHandler)
        |> Map.put(:body_params, %{"type" => "success"})
        |> HandleRequest.call(%{})

      assert conn.status == 200
      assert conn.halted
      assert conn.resp_body =~ ~s("type":4)
      assert conn.resp_body =~ ~s("content":"Success")
    end

    test "handles accepted responses", %{conn: conn} do
      # Define handler for this specific test
      defmodule AcceptedHandler do
        def handle(_interaction), do: :ok
      end

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> assign(:discord_command_handler, AcceptedHandler)
        |> Map.put(:body_params, %{"type" => "accepted"})
        |> HandleRequest.call(%{})

      assert conn.status == 202
      assert conn.halted
    end

    test "handles error responses", %{conn: conn} do
      # Define handler for this specific test
      defmodule ErrorHandler do
        def handle(_interaction), do: :error
      end

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> assign(:discord_command_handler, ErrorHandler)
        |> Map.put(:body_params, %{"type" => "error"})
        |> HandleRequest.call(%{})

      assert conn.status == 500
      assert conn.halted
    end

    test "handles exceptions in command handlers", %{conn: conn} do
      # Define handler for this specific test
      defmodule CrashHandler do
        def handle(_interaction), do: raise("Test exception")
      end

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> assign(:discord_command_handler, CrashHandler)
        |> Map.put(:body_params, %{"type" => "crash"})
        |> HandleRequest.call(%{})

      assert conn.status == 500
      assert conn.halted
    end
  end
end
