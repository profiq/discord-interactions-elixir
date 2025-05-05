defmodule DiscordInteractions.CommandRegistration do
  use Task, restart: :transient

  require Logger
  alias DiscordInteractions.API

  def start_link(handler) do
    Task.start_link(__MODULE__, :register_commands, [handler])
  end

  def register_commands(handler) do
    # Only register global commands at this time
    handler
    |> apply(:init, [])
    |> Map.get(:commands)
    |> Enum.filter(&(&1.guilds == []))
    |> Enum.map(& &1.definition)
    |> register_global_commands()
  end

  def register_global_commands(commands) do
    with {:bot_token, {:ok, bot_token}} <- {:bot_token, Application.fetch_env(:discord_interactions, :bot_token)},
         {:application_id, {:ok, application_id}} <- {:application_id, Application.fetch_env(:discord_interactions, :application_id)},
         client <- API.new(token: bot_token, application_id: application_id),
         {:response, {:ok, _response}} <- {:response, API.bulk_overwrite_global_commands(client, commands)}
    do
      Logger.info("Successfully registered Discord commands")
      :ok
    else
      {:bot_token, _} ->
        Logger.error("Discord bot token is not configured")
        raise "Discord bot token is not configured"

      {:application_id, _} ->
        Logger.error("Discord application ID is not configured")
        raise "Discord application id is not configured"

      {:response, {:error, response}} ->
        Logger.error("Failed to register commands: #{inspect(response)}")
        raise "Failed to register commands"
    end
  end
end
