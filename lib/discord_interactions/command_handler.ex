defmodule DiscordInteractions.CommandHandler do
  @callback init() :: DiscordInteractions.config()
  @callback handle(map()) :: :ok | {:ok, map()} | :error
end
