defmodule DiscordInteractions.Plug.HandleRequest do
  @moduledoc """
  """

  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(%{body_params: %{"type" => 1}} = conn, _opts) do
    resp_body = Jason.encode_to_iodata!(%{type: 1})

    conn
    |> resp(200, resp_body)
    |> put_resp_header("content-type", "application/json")
    |> send_resp()
    |> halt()
  end

  def call(conn, _opts) do
    resp_body =
      Jason.encode_to_iodata!(apply(conn.assigns[:discord_command_handler], :handle, [conn.body_params]))

    conn
    |> resp(200, resp_body)
    |> put_resp_header("content-type", "application/json")
    |> send_resp()
    |> halt()
  end
end
