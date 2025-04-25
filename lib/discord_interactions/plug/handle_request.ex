defmodule DiscordInteractions.Plug.HandleRequest do
  @moduledoc """
  """

  @behaviour Plug

  import DiscordInteractions.Util
  import Plug.Conn

  def init(opts), do: opts

  def call(%{body_params: %{"type" => 1}} = conn, _opts) do
    resp_body = Jason.encode_to_iodata!(%{type: 1})

    conn
    |> resp(200, resp_body)
    |> send_resp()
    |> halt()
  end

  def call(conn, _opts), do: error(conn, :not_implemented)
end
