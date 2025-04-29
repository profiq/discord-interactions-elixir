defmodule DiscordInteractions.CommandHandler do
  @callback init() :: list(map())
  @callback handle(map()) :: map()
end
