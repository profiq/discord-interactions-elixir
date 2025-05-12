defmodule DiscordInteractions.CommandHandler do
  @callback init() :: DiscordInteractions.config()
  @callback handle(map()) :: map()
end
