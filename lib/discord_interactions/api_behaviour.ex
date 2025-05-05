defmodule DiscordInteractions.APIBehaviour do
  @moduledoc """
  Behaviour specification for Discord API interactions.
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

  # Global commands
  @callback new(keyword()) :: client()

  @callback get_global_commands(client()) :: {:ok, commands()} | error()

  @callback get_global_command(client(), command_id()) :: {:ok, command()} | error()

  @callback create_global_command(client(), command()) :: {:ok, command()} | error()

  @callback update_global_command(client(), command_id(), command()) :: {:ok, command()} | error()

  @callback delete_global_command(client(), command_id()) :: :ok | error()

  @callback bulk_overwrite_global_commands(client(), commands()) :: {:ok, commands()} | error()

  # Guild commands
  @callback get_guild_commands(client(), guild_id()) :: {:ok, commands()} | error()

  @callback get_guild_command(client(), guild_id(), command_id()) :: {:ok, command()} | error()

  @callback create_guild_command(client(), guild_id(), command()) :: {:ok, command()} | error()

  @callback update_guild_command(client(), guild_id(), command_id(), command()) ::
              {:ok, command()} | error()

  @callback delete_guild_command(client(), guild_id(), command_id()) :: :ok | error()

  @callback bulk_overwrite_guild_commands(client(), guild_id(), commands()) ::
              {:ok, commands()} | error()

  # Command Permissions
  @callback get_guild_command_permissions(client(), guild_id()) ::
              {:ok, list(permissions())} | error()

  @callback get_command_permissions(client(), guild_id(), command_id()) ::
              {:ok, permissions()} | error()

  @callback update_command_permissions(client(), guild_id(), command_id(), permissions()) ::
              {:ok, permissions()} | error()

  @callback batch_update_command_permissions(client(), guild_id(), list(permissions())) ::
              {:ok, list(permissions())} | error()

  # Interaction responses
  @callback create_interaction_response(client(), interaction_id(), interaction_token(), interaction_response()) ::
              :ok | {:ok, interaction_callback_response()} | error()

  @callback get_original_interaction_response(client(), interaction_token()) ::
              {:ok, message()} | error()

  @callback edit_original_interaction_response(client(), interaction_token(), message()) ::
              {:ok, message()} | error()

  @callback delete_original_interaction_response(client(), interaction_token()) ::
              :ok | error()

  @callback create_followup_message(client(), interaction_token(), message()) ::
              {:ok, message()} | error()

  @callback get_followup_message(client(), interaction_token(), message_id()) ::
              {:ok, message()} | error()

  @callback edit_followup_message(client(), interaction_token(), message_id(), message()) ::
              {:ok, message()} | error()

  @callback delete_followup_message(client(), interaction_token(), message_id()) ::
              :ok | error()
end
