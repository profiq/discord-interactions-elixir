defmodule DiscordInteractions.Util do
  import Plug.Conn

  alias Plug.Conn.Status

  def error(conn, reason) do
    code = Status.code(reason)

    conn
    |> send_resp(code, Status.reason_phrase(code))
    |> halt()
  end
end
