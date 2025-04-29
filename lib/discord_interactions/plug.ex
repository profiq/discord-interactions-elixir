defmodule DiscordInteractions.Plug do
  use Plug.Builder, copy_opts_to_assign: :discord_command_handler

  import DiscordInteractions.Util

  require Logger

  plug(:ensure_post)

  plug(DiscordInteractions.Plug.ValidateRequest)
  plug(DiscordInteractions.Plug.HandleRequest)

  defp ensure_post(%{method: "POST"} = conn, _opts), do: conn
  defp ensure_post(conn, _opts), do: error(conn, :method_not_allowed)
end
