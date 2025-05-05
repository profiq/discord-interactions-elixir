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

  @impl true
  def get_global_commands(%{client: client, application_id: application_id}) do
    case get(client, "/applications/#{application_id}/commands") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def get_global_command(%{client: client, application_id: application_id}, command_id) do
    case get(client, "/applications/#{application_id}/commands/#{command_id}") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def create_global_command(%{client: client, application_id: application_id}, command) do
    case post(client, "/applications/#{application_id}/commands", command) do
      {:ok, %{status: status, body: body}} when status in [200, 201] -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def update_global_command(%{client: client, application_id: application_id}, command_id, command) do
    case patch(client, "/applications/#{application_id}/commands/#{command_id}", command) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def delete_global_command(%{client: client, application_id: application_id}, command_id) do
    case delete(client, "/applications/#{application_id}/commands/#{command_id}") do
      {:ok, %{status: 204}} -> :ok
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def bulk_overwrite_global_commands(%{client: client, application_id: application_id}, commands) do
    case put(client, "/applications/#{application_id}/commands", commands) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  # Guild Commands

  @impl true
  def get_guild_commands(%{client: client, application_id: application_id}, guild_id) do
    case get(client, "/applications/#{application_id}/guilds/#{guild_id}/commands") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def get_guild_command(%{client: client, application_id: application_id}, guild_id, command_id) do
    case get(client, "/applications/#{application_id}/guilds/#{guild_id}/commands/#{command_id}") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def create_guild_command(%{client: client, application_id: application_id}, guild_id, command) do
    case post(client, "/applications/#{application_id}/guilds/#{guild_id}/commands", command) do
      {:ok, %{status: status, body: body}} when status in [200, 201] -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def update_guild_command(%{client: client, application_id: application_id}, guild_id, command_id, command) do
    case patch(client, "/applications/#{application_id}/guilds/#{guild_id}/commands/#{command_id}", command) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def delete_guild_command(%{client: client, application_id: application_id}, guild_id, command_id) do
    case delete(client, "/applications/#{application_id}/guilds/#{guild_id}/commands/#{command_id}") do
      {:ok, %{status: 204}} -> :ok
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def bulk_overwrite_guild_commands(%{client: client, application_id: application_id}, guild_id, commands) do
    case put(client, "/applications/#{application_id}/guilds/#{guild_id}/commands", commands) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  # Command Permissions

  @impl true
  def get_guild_command_permissions(%{client: client, application_id: application_id}, guild_id) do
    case get(client, "/applications/#{application_id}/guilds/#{guild_id}/commands/permissions") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def get_command_permissions(%{client: client, application_id: application_id}, guild_id, command_id) do
    case get(client, "/applications/#{application_id}/guilds/#{guild_id}/commands/#{command_id}/permissions") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def update_command_permissions(%{client: client, application_id: application_id}, guild_id, command_id, permissions) do
    case put(client, "/applications/#{application_id}/guilds/#{guild_id}/commands/#{command_id}/permissions", permissions) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def batch_update_command_permissions(%{client: client, application_id: application_id}, guild_id, permissions) do
    case put(client, "/applications/#{application_id}/guilds/#{guild_id}/commands/permissions", permissions) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  # Interaction Responses

  @impl true
  def create_interaction_response(%{client: client}, interaction_id, interaction_token, response) do
    case post(client, "/interactions/#{interaction_id}/#{interaction_token}/callback", response) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{status: 204}} -> :ok
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def get_original_interaction_response(%{client: client, application_id: application_id}, interaction_token) do
    case get(client, "/webhooks/#{application_id}/#{interaction_token}/messages/@original") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def edit_original_interaction_response(%{client: client, application_id: application_id}, interaction_token, message) do
    case patch(client, "/webhooks/#{application_id}/#{interaction_token}/messages/@original", message) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def delete_original_interaction_response(%{client: client, application_id: application_id}, interaction_token) do
    case delete(client, "/webhooks/#{application_id}/#{interaction_token}/messages/@original") do
      {:ok, %{status: 204}} -> :ok
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def create_followup_message(%{client: client, application_id: application_id}, interaction_token, message) do
    case post(client, "/webhooks/#{application_id}/#{interaction_token}", message) do
      {:ok, %{status: status, body: body}} when status in [200, 201] -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def get_followup_message(%{client: client, application_id: application_id}, interaction_token, message_id) do
    case get(client, "/webhooks/#{application_id}/#{interaction_token}/messages/#{message_id}") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def edit_followup_message(%{client: client, application_id: application_id}, interaction_token, message_id, message) do
    case patch(client, "/webhooks/#{application_id}/#{interaction_token}/messages/#{message_id}", message) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @impl true
  def delete_followup_message(%{client: client, application_id: application_id}, interaction_token, message_id) do
    case delete(client, "/webhooks/#{application_id}/#{interaction_token}/messages/#{message_id}") do
      {:ok, %{status: 204}} -> :ok
      {:ok, response} -> {:error, response}
      error -> error
    end
  end
end
