defmodule DiscordInteractions.CommandRegistrationTest do
  use ExUnit.Case, async: false
  use Mimic

  alias DiscordInteractions.API
  alias DiscordInteractions.CommandRegistration

  defmodule TestHandler do
    def init do
      %{
        global_commands: %{
          "test_global" => %{
            definition: %{name: "test_global", description: "Test global command"}
          }
        },
        guild_commands: %{
          {"guild1", "test_guild1"} => %{
            definition: %{name: "test_guild1", description: "Test guild command 1"}
          },
          {"guild2", "test_guild2"} => %{
            definition: %{name: "test_guild2", description: "Test guild command 2"}
          }
        },
        message_component_handler: nil,
        modal_submit_handler: nil
      }
    end
  end

  defmodule NoGlobalHandler do
    def init do
      %{
        global_commands: %{},
        guild_commands: %{
          {"guild1", "test_guild1"} => %{
            definition: %{name: "test_guild1", description: "Test guild command 1"}
          }
        },
        message_component_handler: nil,
        modal_submit_handler: nil
      }
    end
  end

  defmodule NoGuildHandler do
    def init do
      %{
        global_commands: %{
          "test_global" => %{
            definition: %{name: "test_global", description: "Test global command"}
          }
        },
        guild_commands: %{},
        message_component_handler: nil,
        modal_submit_handler: nil
      }
    end
  end

  setup do
    # Mock the API module for testing - moved here to avoid global interference
    Mimic.copy(DiscordInteractions.API)

    # Set up environment variables for testing
    Application.put_env(:discord_interactions, :bot_token, "test_token")
    Application.put_env(:discord_interactions, :application_id, "test_app_id")

    # Create a mock client for API calls
    client = %{client: :test_client, application_id: "test_app_id"}

    # Return test data
    %{
      client: client,
      handler: TestHandler,
      global_commands: [%{name: "test_global", description: "Test global command"}],
      guild_commands: %{
        "guild1" => [%{name: "test_guild1", description: "Test guild command 1"}],
        "guild2" => [%{name: "test_guild2", description: "Test guild command 2"}]
      }
    }
  end

  describe "register_commands/1" do
    @tag :command_registration
    test "successfully registers both global and guild commands", %{
      client: client,
      global_commands: global_commands,
      guild_commands: guild_commands
    } do
      # Mock API.new to return our test client
      expect(API, :new, fn _opts -> client end)

      # Mock bulk_overwrite_global_commands to return success
      expect(API, :bulk_overwrite_global_commands, fn _client, commands ->
        assert commands == global_commands
        {:ok, commands}
      end)

      # Mock bulk_overwrite_guild_commands for each guild
      Enum.each(guild_commands, fn {guild_id, commands} ->
        expect(API, :bulk_overwrite_guild_commands, fn _client, gid, cmds ->
          assert gid == guild_id
          assert cmds == commands
          {:ok, commands}
        end)
      end)

      # Call the function under test
      assert :ok = CommandRegistration.register_commands(TestHandler)
    end

    @tag :command_registration
    test "handles empty global commands", %{
      client: client,
      guild_commands: guild_commands
    } do
      # Mock API.new to return our test client
      expect(API, :new, fn _opts -> client end)

      # Mock bulk_overwrite_guild_commands for each guild
      expect(API, :bulk_overwrite_guild_commands, fn _client, guild_id, commands ->
        assert guild_id == "guild1"
        assert commands == guild_commands["guild1"]
        {:ok, commands}
      end)

      # Call the function under test
      assert :ok = CommandRegistration.register_commands(NoGlobalHandler)
    end

    @tag :command_registration
    test "handles empty guild commands", %{
      client: client,
      global_commands: global_commands
    } do
      # Mock API.new to return our test client
      expect(API, :new, fn _opts -> client end)

      # Mock bulk_overwrite_global_commands to return success
      expect(API, :bulk_overwrite_global_commands, fn _client, commands ->
        assert commands == global_commands
        {:ok, commands}
      end)

      # Call the function under test
      assert :ok = CommandRegistration.register_commands(NoGuildHandler)
    end

    @tag :command_registration
    test "raises error when global command registration fails", %{
      client: client
    } do
      # Mock API.new to return our test client
      expect(API, :new, fn _opts -> client end)

      # Mock bulk_overwrite_global_commands to return error
      expect(API, :bulk_overwrite_global_commands, fn _client, _commands ->
        {:error, "API error"}
      end)

      # Call the function under test and expect it to raise
      assert_raise RuntimeError, "Failed to register global commands", fn ->
        CommandRegistration.register_commands(TestHandler)
      end
    end

    @tag :command_registration
    test "raises error when guild command registration fails", %{
      client: client,
      global_commands: global_commands
    } do
      # Mock API.new to return our test client
      expect(API, :new, fn _opts -> client end)

      # Mock bulk_overwrite_global_commands to return success
      expect(API, :bulk_overwrite_global_commands, fn _client, _commands ->
        {:ok, global_commands}
      end)

      # Mock bulk_overwrite_guild_commands for guild1 (success)
      expect(API, :bulk_overwrite_guild_commands, fn _client, "guild1", _commands ->
        {:ok, []}
      end)

      # Mock bulk_overwrite_guild_commands for guild2 (failure)
      expect(API, :bulk_overwrite_guild_commands, fn _client, "guild2", _commands ->
        {:error, "API error for guild commands"}
      end)

      # Call the function under test and expect it to raise
      assert_raise RuntimeError, "Failed to register some guild commands", fn ->
        CommandRegistration.register_commands(TestHandler)
      end
    end

    @tag :command_registration
    test "raises error when bot token is not configured" do
      # Store the original bot token config to restore it later
      original_token = Application.get_env(:discord_interactions, :bot_token)

      # Remove the bot token config
      Application.delete_env(:discord_interactions, :bot_token)

      # Ensure cleanup happens even if the test fails
      on_exit(fn ->
        if original_token do
          Application.put_env(:discord_interactions, :bot_token, original_token)
        end
      end)

      # Call the function under test and expect it to raise
      assert_raise RuntimeError, "Discord bot token is not configured", fn ->
        CommandRegistration.register_commands(TestHandler)
      end

      # Restore the bot token config immediately after the test
      Application.put_env(:discord_interactions, :bot_token, original_token)
    end

    @tag :command_registration
    test "raises error when application ID is not configured" do
      # Store the original application ID config to restore it later
      original_app_id = Application.get_env(:discord_interactions, :application_id)

      # Remove the application ID config
      Application.delete_env(:discord_interactions, :application_id)

      # Ensure cleanup happens even if the test fails
      on_exit(fn ->
        if original_app_id do
          Application.put_env(:discord_interactions, :application_id, original_app_id)
        end
      end)

      # Call the function under test and expect it to raise
      assert_raise RuntimeError, "Discord application id is not configured", fn ->
        CommandRegistration.register_commands(TestHandler)
      end

      # Restore the application ID config immediately after the test
      Application.put_env(:discord_interactions, :application_id, original_app_id)
    end
  end
end
