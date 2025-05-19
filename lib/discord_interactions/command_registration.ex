defmodule DiscordInteractions.CommandRegistration do
  @moduledoc """
  Task for registering Discord commands.

  This module is responsible for registering both global and guild-specific commands with Discord.
  It's designed to be added to your application's supervision tree to ensure commands are registered
  when your application starts.

  ## Features

  - Registers global commands (available in all servers where your bot is installed)
  - Registers guild-specific commands (available only in specific servers)
  - Handles errors gracefully with detailed logging
  - Provides feedback on registration success with command counts

  ## Usage

  Add the CommandRegistration task to your application's supervision tree:

  ```elixir
  def start(_type, _args) do
    children = [
      # Other children...
      YourAppWeb.Endpoint,
      {DiscordInteractions.CommandRegistration, YourApp.Discord}
    ]

    opts = [strategy: :one_for_one, name: YourApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
  ```

  The task will automatically register all commands defined in your handler module when your
  application starts.
  """

  use Task, restart: :transient

  require Logger
  alias DiscordInteractions.API

  def start_link(handler) do
    Task.start_link(__MODULE__, :register_commands, [handler])
  end

  def register_commands(handler) do
    config = handler.init()

    # Retrieve global commands
    global_commands =
      config
      |> Map.get(:global_commands)
      |> Enum.map(fn {_name, %{definition: definition}} -> definition end)

    # Retrieve guild commands
    guild_commands =
      config
      |> Map.get(:guild_commands)
      |> Enum.group_by(
        fn {{guild_id, _name}, _command} -> guild_id end,
        fn {{_guild_id, _name}, %{definition: definition}} -> definition end
      )

    # Register both types of commands
    with :ok <- register_global_commands(global_commands),
         :ok <- register_all_guild_commands(guild_commands) do
      :ok
    end
  end

  def register_global_commands([]) do
    Logger.info("No global commands to register")
    :ok
  end

  def register_global_commands(commands) do
    with {:bot_token, {:ok, bot_token}} <-
           {:bot_token, Application.fetch_env(:discord_interactions, :bot_token)},
         {:application_id, {:ok, application_id}} <-
           {:application_id, Application.fetch_env(:discord_interactions, :application_id)},
         client <- API.new(token: bot_token, application_id: application_id),
         {:response, {:ok, _response}} <-
           {:response, API.bulk_overwrite_global_commands(client, commands)} do
      Logger.info("Successfully registered #{length(commands)} global Discord commands")
      :ok
    else
      {:bot_token, _} ->
        Logger.error("Discord bot token is not configured")
        raise "Discord bot token is not configured"

      {:application_id, _} ->
        Logger.error("Discord application ID is not configured")
        raise "Discord application id is not configured"

      {:response, {:error, response}} ->
        Logger.error("Failed to register global commands: #{inspect(response)}")
        raise "Failed to register global commands"
    end
  end

  def register_all_guild_commands(guild_commands) when map_size(guild_commands) == 0 do
    Logger.info("No guild commands to register")
    :ok
  end

  def register_all_guild_commands(guild_commands) do
    with {:bot_token, {:ok, bot_token}} <-
           {:bot_token, Application.fetch_env(:discord_interactions, :bot_token)},
         {:application_id, {:ok, application_id}} <-
           {:application_id, Application.fetch_env(:discord_interactions, :application_id)} do
      client = API.new(token: bot_token, application_id: application_id)

      # Register commands for each guild
      results =
        Enum.map(guild_commands, fn {guild_id, commands} ->
          register_guild_command(client, guild_id, commands)
        end)

      # Check if any registration failed
      if Enum.any?(results, fn result -> result != :ok end) do
        Logger.error("Failed to register some guild commands")
        raise "Failed to register some guild commands"
      else
        Logger.info("Successfully registered commands for #{map_size(guild_commands)} guilds")
        :ok
      end
    else
      {:bot_token, _} ->
        Logger.error("Discord bot token is not configured")
        raise "Discord bot token is not configured"

      {:application_id, _} ->
        Logger.error("Discord application ID is not configured")
        raise "Discord application id is not configured"
    end
  end

  def register_guild_command(_client, _guild_id, []) do
    :ok
  end

  def register_guild_command(client, guild_id, commands) do
    case API.bulk_overwrite_guild_commands(client, guild_id, commands) do
      {:ok, _response} ->
        Logger.info("Successfully registered #{length(commands)} commands for guild #{guild_id}")
        :ok

      {:error, response} ->
        Logger.error("Failed to register commands for guild #{guild_id}: #{inspect(response)}")
        {:error, response}
    end
  end
end
