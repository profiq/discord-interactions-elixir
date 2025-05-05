defmodule DiscordInteractions.APIImpl do
  @moduledoc """
  Discord API client for managing application commands and their permissions.
  """

  @behaviour DiscordInteractions.APIBehaviour

  use Tesla

  @base_url "https://discord.com/api/v10"
  @middleware [
    Tesla.Middleware.JSON,
    {Tesla.Middleware.Headers, [{"content-type", "application/json"}]}
  ]
  @adapter Tesla.Adapter.Httpc

  @impl true
  def new(opts) do
    middleware =
      [
        {Tesla.Middleware.BaseUrl, @base_url <> "/applications/#{opts[:application_id]}"},
        {Tesla.Middleware.Headers, [{"authorization", "Bot #{opts[:token]}"}]}
      ] ++ @middleware

    adapter = opts[:adapter] || @adapter

    Tesla.client(middleware, adapter)
  end

  # Global Commands

  @impl true
  def get_global_commands(client) do
    case get(client, "/commands") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def get_global_command(client, command_id) do
    case get(client, "/commands/#{command_id}") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def create_global_command(client, command) do
    case post(client, "/commands", command) do
      {:ok, %{status: status, body: body}} when status in [200, 201] -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def update_global_command(client, command_id, command) do
    case patch(client, "/commands/#{command_id}", command) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def delete_global_command(client, command_id) do
    case delete(client, "/commands/#{command_id}") do
      {:ok, %{status: 204}} -> :ok
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def bulk_overwrite_global_commands(client, commands) do
    case put(client, "/commands", commands) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  # Guild Commands

  @impl true
  def get_guild_commands(client, guild_id) do
    case get(client, "/guilds/#{guild_id}/commands") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def get_guild_command(client, guild_id, command_id) do
    case get(client, "/guilds/#{guild_id}/commands/#{command_id}") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def create_guild_command(client, guild_id, command) do
    case post(client, "/guilds/#{guild_id}/commands", command) do
      {:ok, %{status: status, body: body}} when status in [200, 201] -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def update_guild_command(client, guild_id, command_id, command) do
    case patch(client, "/guilds/#{guild_id}/commands/#{command_id}", command) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def delete_guild_command(client, guild_id, command_id) do
    case delete(client, "/guilds/#{guild_id}/commands/#{command_id}") do
      {:ok, %{status: 204}} -> :ok
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def bulk_overwrite_guild_commands(client, guild_id, commands) do
    case put(client, "/guilds/#{guild_id}/commands", commands) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  # Command Permissions

  @impl true
  def get_guild_command_permissions(client, guild_id) do
    case get(client, "/guilds/#{guild_id}/commands/permissions") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def get_command_permissions(client, guild_id, command_id) do
    case get(client, "/guilds/#{guild_id}/commands/#{command_id}/permissions") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def update_command_permissions(client, guild_id, command_id, permissions) do
    case put(client, "/guilds/#{guild_id}/commands/#{command_id}/permissions", permissions) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def batch_update_command_permissions(client, guild_id, permissions) do
    case put(client, "/guilds/#{guild_id}/commands/permissions", permissions) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end
end
