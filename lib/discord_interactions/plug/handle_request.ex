defmodule DiscordInteractions.Plug.HandleRequest do
  @moduledoc false

  @behaviour Plug

  import DiscordInteractions.Util
  import Plug.Conn

  require Logger

  alias DiscordInteractions.InteractionResponse

  def init(opts), do: opts

  def call(%{body_params: %{"type" => 1}} = conn, _opts) do
    send_json(conn, InteractionResponse.pong())
  end

  def call(conn, _opts) do
    try do
      case conn.assigns[:discord_command_handler].handle(conn.body_params) do
        :ok ->
          # send 202
          error(conn, :accepted)

        {:ok, response} ->
          send_json(conn, response)

        other ->
          Logger.error("Discord command handler returned unexpected value: #{inspect(other)}")
          error(conn, :internal_server_error)
      end
    rescue
      exception ->
        Logger.error("Discord command handler crashed: #{inspect(exception)}\n#{Exception.format_stacktrace(__STACKTRACE__)}")
        error(conn, :internal_server_error)
    end
  end

  defp send_json(conn, response) do
    case Jason.encode_to_iodata(response) do
      {:ok, resp_body} ->
        conn
        |> resp(200, resp_body)
        |> put_resp_header("content-type", "application/json")
        |> send_resp()
        |> halt()

      {:error, error} ->
        Logger.error("Failed to encode response: #{inspect(error)}")
        error(conn, :internal_server_error)
    end
  end
end
