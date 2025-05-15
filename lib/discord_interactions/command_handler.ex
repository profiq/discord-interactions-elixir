defmodule DiscordInteractions.CommandHandler do
  @moduledoc """
  Behaviour specification for Discord command handlers.
  """

  @callback init() :: DiscordInteractions.config()
  @callback handle(map()) :: :ok | {:ok, map()} | :error
end
