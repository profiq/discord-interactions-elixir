defmodule DiscordInteractions.Util do
  @moduledoc false

  import Plug.Conn

  alias Plug.Conn.Status

  def error(conn, reason) do
    code = Status.code(reason)

    conn
    |> send_resp(code, Status.reason_phrase(code))
    |> halt()
  end
end
