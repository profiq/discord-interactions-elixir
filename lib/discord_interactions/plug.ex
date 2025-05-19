defmodule DiscordInteractions.Plug do
  @moduledoc """
  A Plug for handling Discord interaction webhooks.

  This plug serves as the entry point for Discord interaction requests and implements
  the complete [Discord Interactions API](https://discord.com/developers/docs/interactions/receiving-and-responding)
  webhook flow, including:

  1. Verifying security headers using Ed25519 signatures
  2. Handling ping interactions automatically
  3. Routing command, component, and modal interactions to your handler functions

  ## Usage

  Add this plug to your Phoenix router to handle Discord interaction webhooks:

  ```elixir
  # In your router.ex file
  defmodule YourAppWeb.Router do
    use YourAppWeb, :router

    # Other routes...

    # Route for Discord interactions
    forward "/discord", DiscordInteractions.Plug, YourApp.Discord
  end
  ```

  Where `YourApp.Discord` is a module that uses `DiscordInteractions` and defines
  your interaction handlers.
  """

  use Plug.Builder, copy_opts_to_assign: :discord_command_handler

  import DiscordInteractions.Util

  require Logger

  plug(:ensure_post)

  plug(DiscordInteractions.Plug.ValidateRequest)
  plug(DiscordInteractions.Plug.HandleRequest)

  defp ensure_post(%{method: "POST"} = conn, _opts), do: conn
  defp ensure_post(conn, _opts), do: error(conn, :method_not_allowed)
end
