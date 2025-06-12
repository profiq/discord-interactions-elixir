defmodule DiscordInteractions.APITest do
  use ExUnit.Case, async: false

  alias DiscordInteractions.API

  setup do
    # Create a client with Tesla.Mock adapter
    client =
      API.new(
        application_id: "test_app_id",
        token: "test_token",
        adapter: Tesla.Mock
      )

    %{client: client}
  end

  describe "new/1" do
    test "creates client with correct configuration" do
      client = API.new(application_id: "app_123", token: "bot_token")

      assert client.application_id == "app_123"
      assert is_map(client.client)
    end

    test "uses custom adapter when provided" do
      client =
        API.new(
          application_id: "app_123",
          token: "bot_token",
          adapter: Tesla.Mock
        )

      assert client.application_id == "app_123"
      assert is_map(client.client)
    end
  end

  # Global Commands Tests

  describe "get_global_commands/1" do
    test "returns success response", %{client: client} do
      response_body = [%{id: "123", name: "test", description: "Test command"}]

      Tesla.Mock.mock(fn
        %{method: :get, url: "https://discord.com/api/v10/applications/test_app_id/commands"} ->
          %Tesla.Env{status: 200, body: response_body}
      end)

      assert {:ok, ^response_body} = API.get_global_commands(client)
    end

    test "returns error for non-200 status", %{client: client} do
      Tesla.Mock.mock(fn
        %{method: :get, url: "https://discord.com/api/v10/applications/test_app_id/commands"} ->
          %Tesla.Env{status: 403, body: %{message: "Forbidden"}}
      end)

      assert {:error, %Tesla.Env{status: 403}} = API.get_global_commands(client)
    end

    test "returns Tesla error", %{client: client} do
      Tesla.Mock.mock(fn
        %{method: :get, url: "https://discord.com/api/v10/applications/test_app_id/commands"} ->
          {:error, :timeout}
      end)

      assert {:error, :timeout} = API.get_global_commands(client)
    end
  end

  describe "get_global_command/2" do
    test "returns success response", %{client: client} do
      command_id = "cmd_123"
      response_body = %{id: "cmd_123", name: "test", description: "Test command"}

      Tesla.Mock.mock(fn
        %{
          method: :get,
          url: "https://discord.com/api/v10/applications/test_app_id/commands/cmd_123"
        } ->
          %Tesla.Env{status: 200, body: response_body}
      end)

      assert {:ok, ^response_body} = API.get_global_command(client, command_id)
    end

    test "returns error for non-200 status", %{client: client} do
      command_id = "cmd_123"

      Tesla.Mock.mock(fn
        %{
          method: :get,
          url: "https://discord.com/api/v10/applications/test_app_id/commands/cmd_123"
        } ->
          %Tesla.Env{status: 404, body: %{message: "Not Found"}}
      end)

      assert {:error, %Tesla.Env{status: 404}} = API.get_global_command(client, command_id)
    end
  end

  describe "create_global_command/2" do
    test "returns success response for 200 status", %{client: client} do
      command = %{name: "test", description: "Test command", type: 1}
      response_body = %{id: "123", name: "test", description: "Test command", type: 1}

      Tesla.Mock.mock(fn
        %{method: :post, url: "https://discord.com/api/v10/applications/test_app_id/commands"} ->
          %Tesla.Env{status: 200, body: response_body}
      end)

      assert {:ok, ^response_body} = API.create_global_command(client, command)
    end

    test "returns success response for 201 status", %{client: client} do
      command = %{name: "test", description: "Test command", type: 1}
      response_body = %{id: "123", name: "test", description: "Test command", type: 1}

      Tesla.Mock.mock(fn
        %{method: :post, url: "https://discord.com/api/v10/applications/test_app_id/commands"} ->
          %Tesla.Env{status: 201, body: response_body}
      end)

      assert {:ok, ^response_body} = API.create_global_command(client, command)
    end

    test "returns error for non-success status", %{client: client} do
      command = %{name: "test", description: "Test command", type: 1}

      Tesla.Mock.mock(fn
        %{method: :post, url: "https://discord.com/api/v10/applications/test_app_id/commands"} ->
          %Tesla.Env{status: 400, body: %{message: "Bad Request"}}
      end)

      assert {:error, %Tesla.Env{status: 400}} = API.create_global_command(client, command)
    end
  end

  describe "update_global_command/3" do
    test "returns success response", %{client: client} do
      command_id = "cmd_123"
      command = %{name: "test", description: "Updated description", type: 1}
      response_body = %{id: "cmd_123", name: "test", description: "Updated description", type: 1}

      Tesla.Mock.mock(fn
        %{
          method: :patch,
          url: "https://discord.com/api/v10/applications/test_app_id/commands/cmd_123"
        } ->
          %Tesla.Env{status: 200, body: response_body}
      end)

      assert {:ok, ^response_body} = API.update_global_command(client, command_id, command)
    end

    test "returns error for non-200 status", %{client: client} do
      command_id = "cmd_123"
      command = %{name: "test", description: "Updated description", type: 1}

      Tesla.Mock.mock(fn
        %{
          method: :patch,
          url: "https://discord.com/api/v10/applications/test_app_id/commands/cmd_123"
        } ->
          %Tesla.Env{status: 404, body: %{message: "Not Found"}}
      end)

      assert {:error, %Tesla.Env{status: 404}} =
               API.update_global_command(client, command_id, command)
    end
  end

  describe "delete_global_command/2" do
    test "returns :ok for 204 status", %{client: client} do
      command_id = "cmd_123"

      Tesla.Mock.mock(fn
        %{
          method: :delete,
          url: "https://discord.com/api/v10/applications/test_app_id/commands/cmd_123"
        } ->
          %Tesla.Env{status: 204}
      end)

      assert :ok = API.delete_global_command(client, command_id)
    end

    test "returns error for non-204 status", %{client: client} do
      command_id = "cmd_123"

      Tesla.Mock.mock(fn
        %{
          method: :delete,
          url: "https://discord.com/api/v10/applications/test_app_id/commands/cmd_123"
        } ->
          %Tesla.Env{status: 404, body: %{message: "Not Found"}}
      end)

      assert {:error, %Tesla.Env{status: 404}} = API.delete_global_command(client, command_id)
    end
  end

  describe "bulk_overwrite_global_commands/2" do
    test "returns success response", %{client: client} do
      commands = [%{name: "test", description: "Test command"}]
      response_body = [%{id: "123", name: "test", description: "Test command"}]

      Tesla.Mock.mock(fn
        %{method: :put, url: "https://discord.com/api/v10/applications/test_app_id/commands"} ->
          %Tesla.Env{status: 200, body: response_body}
      end)

      assert {:ok, ^response_body} = API.bulk_overwrite_global_commands(client, commands)
    end

    test "returns error for non-200 status", %{client: client} do
      commands = [%{name: "test", description: "Test command"}]

      Tesla.Mock.mock(fn
        %{method: :put, url: "https://discord.com/api/v10/applications/test_app_id/commands"} ->
          %Tesla.Env{status: 400, body: %{message: "Bad Request"}}
      end)

      assert {:error, %Tesla.Env{status: 400}} =
               API.bulk_overwrite_global_commands(client, commands)
    end

    test "returns Tesla error", %{client: client} do
      commands = [%{name: "test", description: "Test command"}]

      Tesla.Mock.mock(fn
        %{method: :put, url: "https://discord.com/api/v10/applications/test_app_id/commands"} ->
          {:error, :timeout}
      end)

      assert {:error, :timeout} = API.bulk_overwrite_global_commands(client, commands)
    end
  end

  # Guild Commands Tests

  describe "get_guild_commands/2" do
    test "returns success response", %{client: client} do
      guild_id = "guild_123"
      response_body = [%{id: "123", name: "test", description: "Test command"}]

      Tesla.Mock.mock(fn
        %{
          method: :get,
          url: "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands"
        } ->
          %Tesla.Env{status: 200, body: response_body}
      end)

      assert {:ok, ^response_body} = API.get_guild_commands(client, guild_id)
    end

    test "returns error for non-200 status", %{client: client} do
      guild_id = "guild_123"

      Tesla.Mock.mock(fn
        %{
          method: :get,
          url: "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands"
        } ->
          %Tesla.Env{status: 403, body: %{message: "Forbidden"}}
      end)

      assert {:error, %Tesla.Env{status: 403}} = API.get_guild_commands(client, guild_id)
    end
  end

  describe "get_guild_command/3" do
    test "returns success response", %{client: client} do
      guild_id = "guild_123"
      command_id = "cmd_123"
      response_body = %{id: "cmd_123", name: "test", description: "Test command"}

      Tesla.Mock.mock(fn
        %{
          method: :get,
          url:
            "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands/cmd_123"
        } ->
          %Tesla.Env{status: 200, body: response_body}
      end)

      assert {:ok, ^response_body} = API.get_guild_command(client, guild_id, command_id)
    end

    test "returns error for non-200 status", %{client: client} do
      guild_id = "guild_123"
      command_id = "cmd_123"

      Tesla.Mock.mock(fn
        %{
          method: :get,
          url:
            "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands/cmd_123"
        } ->
          %Tesla.Env{status: 404, body: %{message: "Not Found"}}
      end)

      assert {:error, %Tesla.Env{status: 404}} =
               API.get_guild_command(client, guild_id, command_id)
    end
  end

  describe "create_guild_command/3" do
    test "returns success response for 200 status", %{client: client} do
      guild_id = "guild_123"
      command = %{name: "test", description: "Test command", type: 1}
      response_body = %{id: "123", name: "test", description: "Test command", type: 1}

      Tesla.Mock.mock(fn
        %{
          method: :post,
          url: "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands"
        } ->
          %Tesla.Env{status: 200, body: response_body}
      end)

      assert {:ok, ^response_body} = API.create_guild_command(client, guild_id, command)
    end

    test "returns success response for 201 status", %{client: client} do
      guild_id = "guild_123"
      command = %{name: "test", description: "Test command", type: 1}
      response_body = %{id: "123", name: "test", description: "Test command", type: 1}

      Tesla.Mock.mock(fn
        %{
          method: :post,
          url: "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands"
        } ->
          %Tesla.Env{status: 201, body: response_body}
      end)

      assert {:ok, ^response_body} = API.create_guild_command(client, guild_id, command)
    end

    test "returns error for non-success status", %{client: client} do
      guild_id = "guild_123"
      command = %{name: "test", description: "Test command", type: 1}

      Tesla.Mock.mock(fn
        %{
          method: :post,
          url: "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands"
        } ->
          %Tesla.Env{status: 400, body: %{message: "Bad Request"}}
      end)

      assert {:error, %Tesla.Env{status: 400}} =
               API.create_guild_command(client, guild_id, command)
    end
  end

  describe "update_guild_command/4" do
    test "returns success response", %{client: client} do
      guild_id = "guild_123"
      command_id = "cmd_123"
      command = %{name: "test", description: "Updated description", type: 1}
      response_body = %{id: "cmd_123", name: "test", description: "Updated description", type: 1}

      Tesla.Mock.mock(fn
        %{
          method: :patch,
          url:
            "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands/cmd_123"
        } ->
          %Tesla.Env{status: 200, body: response_body}
      end)

      assert {:ok, ^response_body} =
               API.update_guild_command(client, guild_id, command_id, command)
    end

    test "returns error for non-200 status", %{client: client} do
      guild_id = "guild_123"
      command_id = "cmd_123"
      command = %{name: "test", description: "Updated description", type: 1}

      Tesla.Mock.mock(fn
        %{
          method: :patch,
          url:
            "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands/cmd_123"
        } ->
          %Tesla.Env{status: 404, body: %{message: "Not Found"}}
      end)

      assert {:error, %Tesla.Env{status: 404}} =
               API.update_guild_command(client, guild_id, command_id, command)
    end
  end

  describe "delete_guild_command/3" do
    test "returns :ok for 204 status", %{client: client} do
      guild_id = "guild_123"
      command_id = "cmd_123"

      Tesla.Mock.mock(fn
        %{
          method: :delete,
          url:
            "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands/cmd_123"
        } ->
          %Tesla.Env{status: 204}
      end)

      assert :ok = API.delete_guild_command(client, guild_id, command_id)
    end

    test "returns error for non-204 status", %{client: client} do
      guild_id = "guild_123"
      command_id = "cmd_123"

      Tesla.Mock.mock(fn
        %{
          method: :delete,
          url:
            "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands/cmd_123"
        } ->
          %Tesla.Env{status: 404, body: %{message: "Not Found"}}
      end)

      assert {:error, %Tesla.Env{status: 404}} =
               API.delete_guild_command(client, guild_id, command_id)
    end
  end

  describe "bulk_overwrite_guild_commands/3" do
    test "returns success response", %{client: client} do
      guild_id = "guild_123"
      commands = [%{name: "test", description: "Test command"}]
      response_body = [%{id: "123", name: "test", description: "Test command"}]

      Tesla.Mock.mock(fn
        %{
          method: :put,
          url: "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands"
        } ->
          %Tesla.Env{status: 200, body: response_body}
      end)

      assert {:ok, ^response_body} = API.bulk_overwrite_guild_commands(client, guild_id, commands)
    end

    test "returns error for non-200 status", %{client: client} do
      guild_id = "guild_123"
      commands = [%{name: "test", description: "Test command"}]

      Tesla.Mock.mock(fn
        %{
          method: :put,
          url: "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands"
        } ->
          %Tesla.Env{status: 403, body: %{message: "Forbidden"}}
      end)

      assert {:error, %Tesla.Env{status: 403}} =
               API.bulk_overwrite_guild_commands(client, guild_id, commands)
    end
  end

  # Command Permissions Tests

  describe "get_guild_command_permissions/2" do
    test "returns success response", %{client: client} do
      guild_id = "guild_123"

      response_body = [
        %{id: "cmd_123", permissions: [%{id: "role_123", type: 1, permission: true}]}
      ]

      Tesla.Mock.mock(fn
        %{
          method: :get,
          url:
            "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands/permissions"
        } ->
          %Tesla.Env{status: 200, body: response_body}
      end)

      assert {:ok, ^response_body} = API.get_guild_command_permissions(client, guild_id)
    end

    test "returns error for non-200 status", %{client: client} do
      guild_id = "guild_123"

      Tesla.Mock.mock(fn
        %{
          method: :get,
          url:
            "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands/permissions"
        } ->
          %Tesla.Env{status: 403, body: %{message: "Forbidden"}}
      end)

      assert {:error, %Tesla.Env{status: 403}} =
               API.get_guild_command_permissions(client, guild_id)
    end
  end

  describe "get_command_permissions/3" do
    test "returns success response", %{client: client} do
      guild_id = "guild_123"
      command_id = "cmd_123"

      response_body = %{
        id: "cmd_123",
        permissions: [%{id: "role_123", type: 1, permission: true}]
      }

      Tesla.Mock.mock(fn
        %{
          method: :get,
          url:
            "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands/cmd_123/permissions"
        } ->
          %Tesla.Env{status: 200, body: response_body}
      end)

      assert {:ok, ^response_body} = API.get_command_permissions(client, guild_id, command_id)
    end

    test "returns error for non-200 status", %{client: client} do
      guild_id = "guild_123"
      command_id = "cmd_123"

      Tesla.Mock.mock(fn
        %{
          method: :get,
          url:
            "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands/cmd_123/permissions"
        } ->
          %Tesla.Env{status: 404, body: %{message: "Not Found"}}
      end)

      assert {:error, %Tesla.Env{status: 404}} =
               API.get_command_permissions(client, guild_id, command_id)
    end
  end

  describe "update_command_permissions/4" do
    test "returns success response", %{client: client} do
      guild_id = "guild_123"
      command_id = "cmd_123"
      permissions = %{permissions: [%{id: "role_123", type: 1, permission: true}]}

      response_body = %{
        id: "cmd_123",
        permissions: [%{id: "role_123", type: 1, permission: true}]
      }

      Tesla.Mock.mock(fn
        %{
          method: :put,
          url:
            "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands/cmd_123/permissions"
        } ->
          %Tesla.Env{status: 200, body: response_body}
      end)

      assert {:ok, ^response_body} =
               API.update_command_permissions(client, guild_id, command_id, permissions)
    end

    test "returns error for non-200 status", %{client: client} do
      guild_id = "guild_123"
      command_id = "cmd_123"
      permissions = %{permissions: [%{id: "role_123", type: 1, permission: true}]}

      Tesla.Mock.mock(fn
        %{
          method: :put,
          url:
            "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands/cmd_123/permissions"
        } ->
          %Tesla.Env{status: 403, body: %{message: "Forbidden"}}
      end)

      assert {:error, %Tesla.Env{status: 403}} =
               API.update_command_permissions(client, guild_id, command_id, permissions)
    end
  end

  describe "batch_update_command_permissions/3" do
    test "returns success response", %{client: client} do
      guild_id = "guild_123"

      permissions = [
        %{id: "cmd_123", permissions: [%{id: "role_123", type: 1, permission: true}]},
        %{id: "cmd_456", permissions: [%{id: "user_123", type: 2, permission: true}]}
      ]

      response_body = permissions

      Tesla.Mock.mock(fn
        %{
          method: :put,
          url:
            "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands/permissions"
        } ->
          %Tesla.Env{status: 200, body: response_body}
      end)

      assert {:ok, ^response_body} =
               API.batch_update_command_permissions(client, guild_id, permissions)
    end

    test "returns error for non-200 status", %{client: client} do
      guild_id = "guild_123"

      permissions = [
        %{id: "cmd_123", permissions: [%{id: "role_123", type: 1, permission: true}]}
      ]

      Tesla.Mock.mock(fn
        %{
          method: :put,
          url:
            "https://discord.com/api/v10/applications/test_app_id/guilds/guild_123/commands/permissions"
        } ->
          %Tesla.Env{status: 403, body: %{message: "Forbidden"}}
      end)

      assert {:error, %Tesla.Env{status: 403}} =
               API.batch_update_command_permissions(client, guild_id, permissions)
    end
  end

  # Interaction Response Tests

  describe "create_interaction_response/4" do
    test "returns :ok for 204 status", %{client: client} do
      interaction_id = "interaction_123"
      interaction_token = "token_456"
      response = %{type: 4, data: %{content: "Hello"}}

      Tesla.Mock.mock(fn
        %{
          method: :post,
          url: "https://discord.com/api/v10/interactions/interaction_123/token_456/callback"
        } ->
          %Tesla.Env{status: 204}
      end)

      assert :ok =
               API.create_interaction_response(
                 client,
                 interaction_id,
                 interaction_token,
                 response
               )
    end

    test "returns {:ok, body} for 200 status", %{client: client} do
      interaction_id = "interaction_123"
      interaction_token = "token_456"
      response = %{type: 4, data: %{content: "Hello"}}
      response_body = %{id: "message_123"}

      Tesla.Mock.mock(fn
        %{
          method: :post,
          url: "https://discord.com/api/v10/interactions/interaction_123/token_456/callback"
        } ->
          %Tesla.Env{status: 200, body: response_body}
      end)

      assert {:ok, ^response_body} =
               API.create_interaction_response(
                 client,
                 interaction_id,
                 interaction_token,
                 response
               )
    end

    test "returns error for non-success status", %{client: client} do
      interaction_id = "interaction_123"
      interaction_token = "token_456"
      response = %{type: 4, data: %{content: "Hello"}}

      Tesla.Mock.mock(fn
        %{
          method: :post,
          url: "https://discord.com/api/v10/interactions/interaction_123/token_456/callback"
        } ->
          %Tesla.Env{status: 400, body: %{message: "Bad Request"}}
      end)

      assert {:error, %Tesla.Env{status: 400}} =
               API.create_interaction_response(
                 client,
                 interaction_id,
                 interaction_token,
                 response
               )
    end
  end

  describe "get_original_interaction_response/2" do
    test "returns success response", %{client: client} do
      interaction_token = "token_456"
      response_body = %{id: "message_123", content: "Original response"}

      Tesla.Mock.mock(fn
        %{
          method: :get,
          url: "https://discord.com/api/v10/webhooks/test_app_id/token_456/messages/@original"
        } ->
          %Tesla.Env{status: 200, body: response_body}
      end)

      assert {:ok, ^response_body} =
               API.get_original_interaction_response(client, interaction_token)
    end

    test "returns error for non-200 status", %{client: client} do
      interaction_token = "token_456"

      Tesla.Mock.mock(fn
        %{
          method: :get,
          url: "https://discord.com/api/v10/webhooks/test_app_id/token_456/messages/@original"
        } ->
          %Tesla.Env{status: 404, body: %{message: "Not Found"}}
      end)

      assert {:error, %Tesla.Env{status: 404}} =
               API.get_original_interaction_response(client, interaction_token)
    end
  end

  describe "edit_original_interaction_response/3" do
    test "returns success response", %{client: client} do
      interaction_token = "token_456"
      message = %{content: "Updated content"}
      response_body = %{id: "message_123", content: "Updated content"}

      Tesla.Mock.mock(fn
        %{
          method: :patch,
          url: "https://discord.com/api/v10/webhooks/test_app_id/token_456/messages/@original"
        } ->
          %Tesla.Env{status: 200, body: response_body}
      end)

      assert {:ok, ^response_body} =
               API.edit_original_interaction_response(client, interaction_token, message)
    end

    test "returns error for non-200 status", %{client: client} do
      interaction_token = "token_456"
      message = %{content: "Updated content"}

      Tesla.Mock.mock(fn
        %{
          method: :patch,
          url: "https://discord.com/api/v10/webhooks/test_app_id/token_456/messages/@original"
        } ->
          %Tesla.Env{status: 404, body: %{message: "Not Found"}}
      end)

      assert {:error, %Tesla.Env{status: 404}} =
               API.edit_original_interaction_response(client, interaction_token, message)
    end
  end

  describe "delete_original_interaction_response/2" do
    test "returns :ok for 204 status", %{client: client} do
      interaction_token = "token_456"

      Tesla.Mock.mock(fn
        %{
          method: :delete,
          url: "https://discord.com/api/v10/webhooks/test_app_id/token_456/messages/@original"
        } ->
          %Tesla.Env{status: 204}
      end)

      assert :ok = API.delete_original_interaction_response(client, interaction_token)
    end

    test "returns error for non-204 status", %{client: client} do
      interaction_token = "token_456"

      Tesla.Mock.mock(fn
        %{
          method: :delete,
          url: "https://discord.com/api/v10/webhooks/test_app_id/token_456/messages/@original"
        } ->
          %Tesla.Env{status: 404, body: %{message: "Not Found"}}
      end)

      assert {:error, %Tesla.Env{status: 404}} =
               API.delete_original_interaction_response(client, interaction_token)
    end
  end

  describe "create_followup_message/3" do
    test "returns success response for 200 status", %{client: client} do
      interaction_token = "token_456"
      message = %{content: "Followup message"}
      response_body = %{id: "message_123", content: "Followup message"}

      Tesla.Mock.mock(fn
        %{method: :post, url: "https://discord.com/api/v10/webhooks/test_app_id/token_456"} ->
          %Tesla.Env{status: 200, body: response_body}
      end)

      assert {:ok, ^response_body} =
               API.create_followup_message(client, interaction_token, message)
    end

    test "returns success response for 201 status", %{client: client} do
      interaction_token = "token_456"
      message = %{content: "Followup message"}
      response_body = %{id: "message_123", content: "Followup message"}

      Tesla.Mock.mock(fn
        %{method: :post, url: "https://discord.com/api/v10/webhooks/test_app_id/token_456"} ->
          %Tesla.Env{status: 201, body: response_body}
      end)

      assert {:ok, ^response_body} =
               API.create_followup_message(client, interaction_token, message)
    end

    test "returns error for non-success status", %{client: client} do
      interaction_token = "token_456"
      message = %{content: "Followup message"}

      Tesla.Mock.mock(fn
        %{method: :post, url: "https://discord.com/api/v10/webhooks/test_app_id/token_456"} ->
          %Tesla.Env{status: 400, body: %{message: "Bad Request"}}
      end)

      assert {:error, %Tesla.Env{status: 400}} =
               API.create_followup_message(client, interaction_token, message)
    end

    test "returns Tesla error", %{client: client} do
      interaction_token = "token_456"
      message = %{content: "Followup message"}

      Tesla.Mock.mock(fn
        %{method: :post, url: "https://discord.com/api/v10/webhooks/test_app_id/token_456"} ->
          {:error, :timeout}
      end)

      assert {:error, :timeout} = API.create_followup_message(client, interaction_token, message)
    end
  end

  describe "get_followup_message/3" do
    test "returns success response", %{client: client} do
      interaction_token = "token_456"
      message_id = "message_123"
      response_body = %{id: "message_123", content: "Followup message"}

      Tesla.Mock.mock(fn
        %{
          method: :get,
          url: "https://discord.com/api/v10/webhooks/test_app_id/token_456/messages/message_123"
        } ->
          %Tesla.Env{status: 200, body: response_body}
      end)

      assert {:ok, ^response_body} =
               API.get_followup_message(client, interaction_token, message_id)
    end

    test "returns error for non-200 status", %{client: client} do
      interaction_token = "token_456"
      message_id = "message_123"

      Tesla.Mock.mock(fn
        %{
          method: :get,
          url: "https://discord.com/api/v10/webhooks/test_app_id/token_456/messages/message_123"
        } ->
          %Tesla.Env{status: 404, body: %{message: "Not Found"}}
      end)

      assert {:error, %Tesla.Env{status: 404}} =
               API.get_followup_message(client, interaction_token, message_id)
    end
  end

  describe "edit_followup_message/4" do
    test "returns success response", %{client: client} do
      interaction_token = "token_456"
      message_id = "message_123"
      message = %{content: "Updated followup"}
      response_body = %{id: "message_123", content: "Updated followup"}

      Tesla.Mock.mock(fn
        %{
          method: :patch,
          url: "https://discord.com/api/v10/webhooks/test_app_id/token_456/messages/message_123"
        } ->
          %Tesla.Env{status: 200, body: response_body}
      end)

      assert {:ok, ^response_body} =
               API.edit_followup_message(client, interaction_token, message_id, message)
    end

    test "returns error for non-200 status", %{client: client} do
      interaction_token = "token_456"
      message_id = "message_123"
      message = %{content: "Updated followup"}

      Tesla.Mock.mock(fn
        %{
          method: :patch,
          url: "https://discord.com/api/v10/webhooks/test_app_id/token_456/messages/message_123"
        } ->
          %Tesla.Env{status: 404, body: %{message: "Not Found"}}
      end)

      assert {:error, %Tesla.Env{status: 404}} =
               API.edit_followup_message(client, interaction_token, message_id, message)
    end
  end

  describe "delete_followup_message/3" do
    test "returns :ok for 204 status", %{client: client} do
      interaction_token = "token_456"
      message_id = "message_123"

      Tesla.Mock.mock(fn
        %{
          method: :delete,
          url: "https://discord.com/api/v10/webhooks/test_app_id/token_456/messages/message_123"
        } ->
          %Tesla.Env{status: 204}
      end)

      assert :ok = API.delete_followup_message(client, interaction_token, message_id)
    end

    test "returns error for non-204 status", %{client: client} do
      interaction_token = "token_456"
      message_id = "message_123"

      Tesla.Mock.mock(fn
        %{
          method: :delete,
          url: "https://discord.com/api/v10/webhooks/test_app_id/token_456/messages/message_123"
        } ->
          %Tesla.Env{status: 404, body: %{message: "Not Found"}}
      end)

      assert {:error, %Tesla.Env{status: 404}} =
               API.delete_followup_message(client, interaction_token, message_id)
    end
  end
end
