defmodule DiscordInteractions.APIImpl do
  @moduledoc """
  Discord API client for managing application commands and their permissions.
  """

  @type client :: term()
  @type application_id :: String.t()
  @type guild_id :: String.t()
  @type command_id :: String.t()
  @type command :: map()
  @type commands :: list(command())
  @type permissions :: map()
  @type interaction_response :: map()
  @type interaction_id :: String.t()
  @type interaction_token :: String.t()
  @type interaction_callback_response :: map()
  @type message :: map()
  @type message_id :: String.t()
  @type error :: {:error, any()}

  use Tesla

  @base_url "https://discord.com/api/v10"
  @middleware [
    Tesla.Middleware.JSON,
    {Tesla.Middleware.Headers, [{"content-type", "application/json"}]}
  ]
  @adapter Tesla.Adapter.Httpc

  @doc """
  Creates a new API client with the given token.

  ## Examples

      iex> client = DiscordInteractions.Client.new(application_id: "APP_ID", token: "BOT_TOKEN")
  """
  @spec new(keyword()) :: client()
  def new(opts) do
    middleware =
      [
        {Tesla.Middleware.BaseUrl, @base_url},
        {Tesla.Middleware.Headers, [{"authorization", "Bot #{opts[:token]}"}]}
      ] ++ @middleware

    adapter = opts[:adapter] || @adapter

    %{
      client: Tesla.client(middleware, adapter),
      application_id: opts[:application_id]
    }
  end

  # Global Commands

  @doc """
  Gets all global commands for the application.

  ## Examples

      iex> {:ok, commands} = DiscordInteractions.Client.get_global_commands(client)
  """
  @spec get_global_commands(client()) :: {:ok, commands()} | error()
  def get_global_commands(%{client: client, application_id: application_id}) do
    case get(client, "/applications/#{application_id}/commands") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @doc """
  Gets a specific global command by ID.

  ## Examples

      iex> {:ok, command} = DiscordInteractions.Client.get_global_command(client, "CMD_ID")
  """
  @spec get_global_command(client(), command_id()) :: {:ok, command()} | error()
  def get_global_command(%{client: client, application_id: application_id}, command_id) do
    case get(client, "/applications/#{application_id}/commands/#{command_id}") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @doc """
  Creates a new global command.

  ## Examples

      iex> command = %{name: "test", description: "A test command", type: 1}
      iex> {:ok, created} = DiscordInteractions.Client.create_global_command(client, command)
  """
  @spec create_global_command(client(), command()) :: {:ok, command()} | error()
  def create_global_command(%{client: client, application_id: application_id}, command) do
    case post(client, "/applications/#{application_id}/commands", command) do
      {:ok, %{status: status, body: body}} when status in [200, 201] -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @doc """
  Updates an existing global command.

  ## Examples

      iex> command = %{name: "test", description: "Updated description", type: 1}
      iex> {:ok, updated} = DiscordInteractions.Client.update_global_command(client, "CMD_ID", command)
  """
  @spec update_global_command(client(), command_id(), command()) :: {:ok, command()} | error()
  def update_global_command(
        %{client: client, application_id: application_id},
        command_id,
        command
      ) do
    case patch(client, "/applications/#{application_id}/commands/#{command_id}", command) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @doc """
  Deletes a global command.

  ## Examples

      iex> :ok = DiscordInteractions.Client.delete_global_command(client, "CMD_ID")
  """
  @spec delete_global_command(client(), command_id()) :: :ok | error()
  def delete_global_command(%{client: client, application_id: application_id}, command_id) do
    case delete(client, "/applications/#{application_id}/commands/#{command_id}") do
      {:ok, %{status: 204}} -> :ok
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @doc """
  Bulk overwrites all global commands.

  ## Examples

      iex> commands = [%{name: "cmd1", description: "Command 1"}, %{name: "cmd2", description: "Command 2"}]
      iex> {:ok, updated} = DiscordInteractions.Client.bulk_overwrite_global_commands(client, commands)
  """
  @spec bulk_overwrite_global_commands(client(), commands()) :: {:ok, commands()} | error()
  def bulk_overwrite_global_commands(%{client: client, application_id: application_id}, commands) do
    case put(client, "/applications/#{application_id}/commands", commands) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  # Guild Commands

  @doc """
  Gets all commands for a specific guild.

  ## Examples

      iex> {:ok, commands} = DiscordInteractions.Client.get_guild_commands(client, "GUILD_ID")
  """
  @spec get_guild_commands(client(), guild_id()) :: {:ok, commands()} | error()
  def get_guild_commands(%{client: client, application_id: application_id}, guild_id) do
    case get(client, "/applications/#{application_id}/guilds/#{guild_id}/commands") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @doc """
  Gets a specific command in a guild.

  ## Examples

      iex> {:ok, command} = DiscordInteractions.Client.get_guild_command(client, "GUILD_ID", "CMD_ID")
  """
  @spec get_guild_command(client(), guild_id(), command_id()) :: {:ok, command()} | error()
  def get_guild_command(%{client: client, application_id: application_id}, guild_id, command_id) do
    case get(client, "/applications/#{application_id}/guilds/#{guild_id}/commands/#{command_id}") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @doc """
  Creates a new command in a guild.

  ## Examples

      iex> command = %{name: "test", description: "A test command", type: 1}
      iex> {:ok, created} = DiscordInteractions.Client.create_guild_command(client, "GUILD_ID", command)
  """
  @spec create_guild_command(client(), guild_id(), command()) :: {:ok, command()} | error()
  def create_guild_command(%{client: client, application_id: application_id}, guild_id, command) do
    case post(client, "/applications/#{application_id}/guilds/#{guild_id}/commands", command) do
      {:ok, %{status: status, body: body}} when status in [200, 201] -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @doc """
  Updates an existing command in a guild.

  ## Examples

      iex> command = %{name: "test", description: "Updated description", type: 1}
      iex> {:ok, updated} = DiscordInteractions.Client.update_guild_command(client, "GUILD_ID", "CMD_ID", command)
  """
  @spec update_guild_command(client(), guild_id(), command_id(), command()) ::
          {:ok, command()} | error()
  def update_guild_command(
        %{client: client, application_id: application_id},
        guild_id,
        command_id,
        command
      ) do
    case patch(
           client,
           "/applications/#{application_id}/guilds/#{guild_id}/commands/#{command_id}",
           command
         ) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @doc """
  Deletes a command from a guild.

  ## Examples

      iex> :ok = DiscordInteractions.Client.delete_guild_command(client, "GUILD_ID", "CMD_ID")
  """
  @spec delete_guild_command(client(), guild_id(), command_id()) :: :ok | error()
  def delete_guild_command(
        %{client: client, application_id: application_id},
        guild_id,
        command_id
      ) do
    case delete(
           client,
           "/applications/#{application_id}/guilds/#{guild_id}/commands/#{command_id}"
         ) do
      {:ok, %{status: 204}} -> :ok
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @doc """
  Bulk overwrites all commands in a guild.

  ## Examples

      iex> commands = [%{name: "cmd1", description: "Command 1"}, %{name: "cmd2", description: "Command 2"}]
      iex> {:ok, updated} = DiscordInteractions.Client.bulk_overwrite_guild_commands(client, "GUILD_ID", commands)
  """
  @spec bulk_overwrite_guild_commands(client(), guild_id(), commands()) ::
          {:ok, commands()} | error()
  def bulk_overwrite_guild_commands(
        %{client: client, application_id: application_id},
        guild_id,
        commands
      ) do
    case put(client, "/applications/#{application_id}/guilds/#{guild_id}/commands", commands) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  # Command Permissions

  @doc """
  Gets permissions for all commands in a guild.

  ## Examples

      iex> {:ok, permissions} = DiscordInteractions.Client.get_guild_command_permissions(client, "GUILD_ID")
  """
  @spec get_guild_command_permissions(client(), guild_id()) ::
          {:ok, list(permissions())} | error()
  def get_guild_command_permissions(%{client: client, application_id: application_id}, guild_id) do
    case get(client, "/applications/#{application_id}/guilds/#{guild_id}/commands/permissions") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @doc """
  Gets permissions for a specific command in a guild.

  ## Examples

      iex> {:ok, permissions} = DiscordInteractions.Client.get_command_permissions(client, "GUILD_ID", "CMD_ID")
  """
  @spec get_command_permissions(client(), guild_id(), command_id()) ::
          {:ok, permissions()} | error()
  def get_command_permissions(
        %{client: client, application_id: application_id},
        guild_id,
        command_id
      ) do
    case get(
           client,
           "/applications/#{application_id}/guilds/#{guild_id}/commands/#{command_id}/permissions"
         ) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @doc """
  Updates permissions for a specific command in a guild.

  ## Examples

      iex> permissions = %{permissions: [%{id: "ROLE_ID", type: 1, permission: true}]}
      iex> {:ok, updated} = DiscordInteractions.Client.update_command_permissions(client, "GUILD_ID", "CMD_ID", permissions)
  """
  @spec update_command_permissions(client(), guild_id(), command_id(), permissions()) ::
          {:ok, permissions()} | error()
  def update_command_permissions(
        %{client: client, application_id: application_id},
        guild_id,
        command_id,
        permissions
      ) do
    case put(
           client,
           "/applications/#{application_id}/guilds/#{guild_id}/commands/#{command_id}/permissions",
           permissions
         ) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
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
  @spec batch_update_command_permissions(client(), guild_id(), list(permissions())) ::
          {:ok, list(permissions())} | error()
  def batch_update_command_permissions(
        %{client: client, application_id: application_id},
        guild_id,
        permissions
      ) do
    case put(
           client,
           "/applications/#{application_id}/guilds/#{guild_id}/commands/permissions",
           permissions
         ) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  # Interaction Responses

  @doc """
  Creates an initial response to an interaction.

  ## Examples

      iex> response = %{type: 4, data: %{content: "Hello!"}}
      iex> :ok = DiscordInteractions.Client.create_interaction_response(client, "INTERACTION_ID", "INTERACTION_TOKEN", response)
  """
  @spec create_interaction_response(
          client(),
          interaction_id(),
          interaction_token(),
          interaction_response()
        ) :: :ok | {:ok, interaction_callback_response()} | error()
  def create_interaction_response(%{client: client}, interaction_id, interaction_token, response) do
    case post(client, "/interactions/#{interaction_id}/#{interaction_token}/callback", response) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{status: 204}} -> :ok
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @doc """
  Gets the initial response to an interaction.

  ## Examples

      iex> {:ok, message} = DiscordInteractions.Client.get_original_interaction_response(client, "INTERACTION_TOKEN")
  """
  @spec get_original_interaction_response(client(), interaction_token()) ::
          {:ok, message()} | error()
  def get_original_interaction_response(
        %{client: client, application_id: application_id},
        interaction_token
      ) do
    case get(client, "/webhooks/#{application_id}/#{interaction_token}/messages/@original") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @doc """
  Edits the initial response to an interaction.

  ## Examples

      iex> message = %{content: "Updated content"}
      iex> {:ok, updated} = DiscordInteractions.Client.edit_original_interaction_response(client, "INTERACTION_TOKEN", message)
  """
  @spec edit_original_interaction_response(client(), interaction_token(), message()) ::
          {:ok, message()} | error()
  def edit_original_interaction_response(
        %{client: client, application_id: application_id},
        interaction_token,
        message
      ) do
    case patch(
           client,
           "/webhooks/#{application_id}/#{interaction_token}/messages/@original",
           message
         ) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @doc """
  Deletes the initial response to an interaction.

  ## Examples

      iex> :ok = DiscordInteractions.Client.delete_original_interaction_response(client, "INTERACTION_TOKEN")
  """
  @spec delete_original_interaction_response(client(), interaction_token()) :: :ok | error()
  def delete_original_interaction_response(
        %{client: client, application_id: application_id},
        interaction_token
      ) do
    case delete(client, "/webhooks/#{application_id}/#{interaction_token}/messages/@original") do
      {:ok, %{status: 204}} -> :ok
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @doc """
  Creates a followup message for an interaction.

  ## Examples

      iex> message = %{content: "Followup message"}
      iex> {:ok, created} = DiscordInteractions.Client.create_followup_message(client, "INTERACTION_TOKEN", message)
  """
  @spec create_followup_message(client(), interaction_token(), message()) ::
          {:ok, message()} | error()
  def create_followup_message(
        %{client: client, application_id: application_id},
        interaction_token,
        message
      ) do
    case post(client, "/webhooks/#{application_id}/#{interaction_token}", message) do
      {:ok, %{status: status, body: body}} when status in [200, 201] -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @doc """
  Gets a followup message for an interaction.

  ## Examples

      iex> {:ok, message} = DiscordInteractions.Client.get_followup_message(client, "INTERACTION_TOKEN", "MESSAGE_ID")
  """
  @spec get_followup_message(client(), interaction_token(), message_id()) ::
          {:ok, message()} | error()
  def get_followup_message(
        %{client: client, application_id: application_id},
        interaction_token,
        message_id
      ) do
    case get(client, "/webhooks/#{application_id}/#{interaction_token}/messages/#{message_id}") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @doc """
  Edits a followup message for an interaction.

  ## Examples

      iex> message = %{content: "Updated followup"}
      iex> {:ok, updated} = DiscordInteractions.Client.edit_followup_message(client, "INTERACTION_TOKEN", "MESSAGE_ID", message)
  """
  @spec edit_followup_message(client(), interaction_token(), message_id(), message()) ::
          {:ok, message()} | error()
  def edit_followup_message(
        %{client: client, application_id: application_id},
        interaction_token,
        message_id,
        message
      ) do
    case patch(
           client,
           "/webhooks/#{application_id}/#{interaction_token}/messages/#{message_id}",
           message
         ) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @doc """
  Deletes a followup message for an interaction.

  ## Examples

      iex> :ok = DiscordInteractions.Client.delete_followup_message(client, "INTERACTION_TOKEN", "MESSAGE_ID")
  """
  @spec delete_followup_message(client(), interaction_token(), message_id()) :: :ok | error()
  def delete_followup_message(
        %{client: client, application_id: application_id},
        interaction_token,
        message_id
      ) do
    case delete(client, "/webhooks/#{application_id}/#{interaction_token}/messages/#{message_id}") do
      {:ok, %{status: 204}} -> :ok
      {:ok, response} -> {:error, response}
      error -> error
    end
  end
end
