defmodule DiscordInteractions.CommandHandler do
  @moduledoc """
  Behaviour specification for Discord command handlers.

  ## Return Values

  The `handle/1` callback should return one of:

  - `{:ok, response}` - Successful response with data (200 OK)
  - `:ok` - Success with no response data (202 Accepted)
  - `:error` - Error handling the interaction (500 Internal Server Error)
  """

  @callback init() :: DiscordInteractions.config()
  @callback handle(map()) :: :ok | {:ok, map()}
end
