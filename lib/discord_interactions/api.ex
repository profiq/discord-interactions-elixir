defmodule DiscordInteractions.API do
  @behaviour DiscordInteractions.APIBehaviour

  @api_module Application.compile_env(:discord_interactions, :api_impl, DiscordInteractions.APIImpl)

  @doc """
  Creates a new API client with the given token.

  ## Examples

      iex> client = DiscordInteractions.Client.new(application_id: "APP_ID", token: "BOT_TOKEN")
  """
  @impl true
  def new(opts), do: @api_module.new(opts)

  # Global Commands

  @doc """
  Gets all global commands for the application.

  ## Examples

      iex> {:ok, commands} = DiscordInteractions.Client.get_global_commands(client)
  """
  @impl true
  def get_global_commands(client) do
    @api_module.get_global_commands(client)
  end

  @doc """
  Gets a specific global command by ID.

  ## Examples

      iex> {:ok, command} = DiscordInteractions.Client.get_global_command(client, "CMD_ID")
  """
  @impl true
  def get_global_command(client, command_id) do
    @api_module.get_global_command(client, command_id)
  end

  @doc """
  Creates a new global command.

  ## Examples

      iex> command = %{name: "test", description: "A test command", type: 1}
      iex> {:ok, created} = DiscordInteractions.Client.create_global_command(client, command)
  """
  @impl true
  def create_global_command(client, command) do
    @api_module.create_global_command(client, command)
  end

  @doc """
  Updates an existing global command.

  ## Examples

      iex> command = %{name: "test", description: "Updated description", type: 1}
      iex> {:ok, updated} = DiscordInteractions.Client.update_global_command(client, "CMD_ID", command)
  """
  @impl true
  def update_global_command(client, command_id, command) do
    @api_module.update_global_command(client, command_id, command)
  end

  @doc """
  Deletes a global command.

  ## Examples

      iex> :ok = DiscordInteractions.Client.delete_global_command(client, "CMD_ID")
  """
  @impl true
  def delete_global_command(client, command_id) do
    @api_module.delete_global_command(client, command_id)
  end

  @doc """
  Bulk overwrites all global commands.

  ## Examples

      iex> commands = [%{name: "cmd1", description: "Command 1"}, %{name: "cmd2", description: "Command 2"}]
      iex> {:ok, updated} = DiscordInteractions.Client.bulk_overwrite_global_commands(client, commands)
  """
  @impl true
  def bulk_overwrite_global_commands(client, commands) do
    @api_module.bulk_overwrite_global_commands(client, commands)
  end

  # Guild Commands

  @doc """
  Gets all commands for a specific guild.

  ## Examples

      iex> {:ok, commands} = DiscordInteractions.Client.get_guild_commands(client, "GUILD_ID")
  """
  @impl true
  def get_guild_commands(client, guild_id) do
    @api_module.get_guild_commands(client, guild_id)
  end

  @doc """
  Gets a specific command in a guild.

  ## Examples

      iex> {:ok, command} = DiscordInteractions.Client.get_guild_command(client, "GUILD_ID", "CMD_ID")
  """
  @impl true
  def get_guild_command(client, guild_id, command_id) do
    @api_module.get_guild_command(client, guild_id, command_id)
  end

  @doc """
  Creates a new command in a guild.

  ## Examples

      iex> command = %{name: "test", description: "A test command", type: 1}
      iex> {:ok, created} = DiscordInteractions.Client.create_guild_command(client, "GUILD_ID", command)
  """
  @impl true
  def create_guild_command(client, guild_id, command) do
    @api_module.create_guild_command(client, guild_id, command)
  end

  @doc """
  Updates an existing command in a guild.

  ## Examples

      iex> command = %{name: "test", description: "Updated description", type: 1}
      iex> {:ok, updated} = DiscordInteractions.Client.update_guild_command(client, "GUILD_ID", "CMD_ID", command)
  """
  @impl true
  def update_guild_command(client, guild_id, command_id, command) do
    @api_module.update_guild_command(client, guild_id, command_id, command)
  end

  @doc """
  Deletes a command from a guild.

  ## Examples

      iex> :ok = DiscordInteractions.Client.delete_guild_command(client, "GUILD_ID", "CMD_ID")
  """
  @impl true
  def delete_guild_command(client, guild_id, command_id) do
    @api_module.delete_guild_command(client, guild_id, command_id)
  end

  @doc """
  Bulk overwrites all commands in a guild.

  ## Examples

      iex> commands = [%{name: "cmd1", description: "Command 1"}, %{name: "cmd2", description: "Command 2"}]
      iex> {:ok, updated} = DiscordInteractions.Client.bulk_overwrite_guild_commands(client, "GUILD_ID", commands)
  """
  @impl true
  def bulk_overwrite_guild_commands(client, guild_id, commands) do
    @api_module.bulk_overwrite_guild_commands(client, guild_id, commands)
  end

  # Command Permissions

  @doc """
  Gets permissions for all commands in a guild.

  ## Examples

      iex> {:ok, permissions} = DiscordInteractions.Client.get_guild_command_permissions(client, "GUILD_ID")
  """
  @impl true
  def get_guild_command_permissions(client, guild_id) do
    @api_module.get_guild_command_permissions(client, guild_id)
  end

  @doc """
  Gets permissions for a specific command in a guild.

  ## Examples

      iex> {:ok, permissions} = DiscordInteractions.Client.get_command_permissions(client, "GUILD_ID", "CMD_ID")
  """
  @impl true
  def get_command_permissions(client, guild_id, command_id) do
    @api_module.get_command_permissions(client, guild_id, command_id)
  end

  @doc """
  Updates permissions for a specific command in a guild.

  ## Examples

      iex> permissions = %{permissions: [%{id: "ROLE_ID", type: 1, permission: true}]}
      iex> {:ok, updated} = DiscordInteractions.Client.update_command_permissions(client, "GUILD_ID", "CMD_ID", permissions)
  """
  @impl true
  def update_command_permissions(client, guild_id, command_id, permissions) do
    @api_module.update_command_permissions(client, guild_id, command_id, permissions)
  end

  @doc """
  Batch updates permissions for multiple commands in a guild.

  ## Examples

      iex> permissions = [
      ...>   %{id: "CMD_ID_1", permissions: [%{id: "ROLE_ID", type: 1, permission: true}]},
      ...>   %{id: "CMD_ID_2", permissions: [%{id: "USER_ID", type: 2, permission: true}]}
      ...> ]
      iex> {:ok, updated} = DiscordInteractions.Client.batch_update_command_permissions(client, "GUILD_ID", permissions)
  """
  @impl true
  def batch_update_command_permissions(client, guild_id, permissions) do
    @api_module.batch_update_command_permissions(client, guild_id, permissions)
  end
end
