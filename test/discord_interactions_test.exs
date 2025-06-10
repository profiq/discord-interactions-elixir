defmodule DiscordInteractionsTest do
  use ExUnit.Case
  doctest DiscordInteractions

  defmodule TestHandler do
    use DiscordInteractions

    interactions do
      application_command "test", :chat_input do
        description("A test command")
        handler(&test_command/1)
      end

      application_command "guild_test", :chat_input do
        description("A guild test command")
        guild("test_guild")
        handler(&guild_test_command/1)
      end

      application_command "User Command", :user do
        handler(&user_command/1)
      end

      application_command "Message Command", :message do
        handler(&message_command/1)
      end

      application_command "multi_guild", :chat_input do
        description("A command for multiple guilds")
        guild("guild1")
        guild("guild2")
        handler(&multi_guild_command/1)
      end

      application_command "echo", :chat_input do
        description("Echo command with options")

        option("message", :string,
          description: "The message to echo",
          required: true
        )

        option("count", :integer,
          description: "Number of times to repeat",
          min_value: 1,
          max_value: 10,
          required: false
        )

        option("public", :boolean,
          description: "Whether to make the response public",
          required: false
        )

        handler(&echo_command/1)
      end

      application_command "autocomplete_test", :chat_input do
        description("Command with autocomplete")

        option("query", :string,
          description: "Search query",
          autocomplete: true,
          required: true
        )

        handler(&autocomplete_test_command/1)
        autocomplete_handler(&handle_autocomplete/1)
      end

      message_component_handler(&component_handler/1)
      modal_submit_handler(&modal_handler/1)
    end

    def test_command(_interaction) do
      {:ok, %{type: 4, data: %{content: "Test response"}}}
    end

    def guild_test_command(_interaction) do
      {:ok, %{type: 4, data: %{content: "Guild test response"}}}
    end

    def user_command(_interaction) do
      {:ok, %{type: 4, data: %{content: "User command response"}}}
    end

    def message_command(_interaction) do
      {:ok, %{type: 4, data: %{content: "Message command response"}}}
    end

    def multi_guild_command(_interaction) do
      {:ok, %{type: 4, data: %{content: "Multi-guild response"}}}
    end

    def echo_command(_interaction) do
      {:ok, %{type: 4, data: %{content: "Echo response"}}}
    end

    def autocomplete_test_command(_interaction) do
      {:ok, %{type: 4, data: %{content: "Autocomplete test response"}}}
    end

    def handle_autocomplete(_interaction) do
      {:ok, %{type: 8, data: %{choices: [%{name: "test", value: "test"}]}}}
    end

    def component_handler(_interaction) do
      {:ok, %{type: 4, data: %{content: "Component response"}}}
    end

    def modal_handler(_interaction) do
      {:ok, %{type: 4, data: %{content: "Modal response"}}}
    end
  end

  describe "using DiscordInteractions" do
    test "generates handle/1 function for application commands" do
      # Test global command
      interaction = %{
        "type" => 2,
        "data" => %{"name" => "test"},
        "guild_id" => "some_guild"
      }

      assert {:ok, %{type: 4, data: %{content: "Test response"}}} = TestHandler.handle(interaction)
    end

    test "handles guild-specific commands" do
      # Test guild command
      interaction = %{
        "type" => 2,
        "data" => %{"name" => "guild_test"},
        "guild_id" => "test_guild"
      }

      assert {:ok, %{type: 4, data: %{content: "Guild test response"}}} = TestHandler.handle(interaction)
    end

    test "handles user context menu commands" do
      interaction = %{
        "type" => 2,
        "data" => %{"name" => "User Command"},
        "guild_id" => "some_guild"
      }

      assert {:ok, %{type: 4, data: %{content: "User command response"}}} = TestHandler.handle(interaction)
    end

    test "handles message context menu commands" do
      interaction = %{
        "type" => 2,
        "data" => %{"name" => "Message Command"},
        "guild_id" => "some_guild"
      }

      assert {:ok, %{type: 4, data: %{content: "Message command response"}}} = TestHandler.handle(interaction)
    end

    test "handles commands with multiple guilds" do
      # Test command in first guild
      interaction1 = %{
        "type" => 2,
        "data" => %{"name" => "multi_guild"},
        "guild_id" => "guild1"
      }

      assert {:ok, %{type: 4, data: %{content: "Multi-guild response"}}} = TestHandler.handle(interaction1)

      # Test command in second guild
      interaction2 = %{
        "type" => 2,
        "data" => %{"name" => "multi_guild"},
        "guild_id" => "guild2"
      }

      assert {:ok, %{type: 4, data: %{content: "Multi-guild response"}}} = TestHandler.handle(interaction2)
    end

    test "handles commands with options" do
      interaction = %{
        "type" => 2,
        "data" => %{"name" => "echo"},
        "guild_id" => "some_guild"
      }

      assert {:ok, %{type: 4, data: %{content: "Echo response"}}} = TestHandler.handle(interaction)
    end

    test "handles autocomplete interactions" do
      interaction = %{
        "type" => 4,
        "data" => %{"name" => "autocomplete_test"}
      }

      assert {:ok, %{type: 8, data: %{choices: [%{name: "test", value: "test"}]}}} = TestHandler.handle(interaction)
    end

    test "handles message components" do
      interaction = %{
        "type" => 3,
        "data" => %{"custom_id" => "test_button"}
      }

      assert {:ok, %{type: 4, data: %{content: "Component response"}}} = TestHandler.handle(interaction)
    end

    test "handles modal submissions" do
      interaction = %{
        "type" => 5,
        "data" => %{"custom_id" => "test_modal"}
      }

      assert {:ok, %{type: 4, data: %{content: "Modal response"}}} = TestHandler.handle(interaction)
    end

    test "returns :error for unknown commands" do
      interaction = %{
        "type" => 2,
        "data" => %{"name" => "unknown"},
        "guild_id" => "some_guild"
      }

      assert :error = TestHandler.handle(interaction)
    end

    test "returns :error for commands without handlers" do
      interaction = %{
        "type" => 3,
        "data" => %{"custom_id" => "test_button"}
      }

      # Create a handler without message component handler
      defmodule NoComponentHandler do
        use DiscordInteractions

        interactions do
          application_command "test", :chat_input do
            description("A test command")
            handler(&test_command/1)
          end
        end

        def test_command(_interaction) do
          {:ok, %{type: 4, data: %{content: "Test response"}}}
        end
      end

      assert :error = NoComponentHandler.handle(interaction)
    end

    test "returns :error for modal submissions without handler" do
      interaction = %{
        "type" => 5,
        "data" => %{"custom_id" => "test_modal"}
      }

      # Create a handler without modal submit handler
      defmodule NoModalHandler do
        use DiscordInteractions

        interactions do
          application_command "test", :chat_input do
            description("A test command")
            handler(&test_command/1)
          end
        end

        def test_command(_interaction) do
          {:ok, %{type: 4, data: %{content: "Test response"}}}
        end
      end

      assert :error = NoModalHandler.handle(interaction)
    end

    test "returns :error for autocomplete without handler" do
      interaction = %{
        "type" => 4,
        "data" => %{"name" => "test"}
      }

      # Create a handler without autocomplete handler
      defmodule NoAutocompleteHandler do
        use DiscordInteractions

        interactions do
          application_command "test", :chat_input do
            description("A test command")
            handler(&test_command/1)
          end
        end

        def test_command(_interaction) do
          {:ok, %{type: 4, data: %{content: "Test response"}}}
        end
      end

      assert :error = NoAutocompleteHandler.handle(interaction)
    end
  end

  describe "command configuration" do
    test "generates correct command definitions" do
      config = TestHandler.init()

      # Test global command
      assert %{
        definition: %{name: "test", type: 1},
        handler: handler,
        guilds: []
      } = config.global_commands["test"]
      assert is_function(handler, 1)

      # Test user command
      assert %{
        definition: %{name: "User Command", type: 2},
        handler: handler,
        guilds: []
      } = config.global_commands["User Command"]
      assert is_function(handler, 1)

      # Test message command
      assert %{
        definition: %{name: "Message Command", type: 3},
        handler: handler,
        guilds: []
      } = config.global_commands["Message Command"]
      assert is_function(handler, 1)

      # Test guild command
      assert %{
        definition: %{name: "guild_test", type: 1},
        handler: handler,
        guilds: ["test_guild"]
      } = config.guild_commands[{"test_guild", "guild_test"}]
      assert is_function(handler, 1)

      # Test multi-guild command
      assert %{
        definition: %{name: "multi_guild", type: 1},
        handler: handler,
        guilds: ["guild2", "guild1"]  # Order is reversed due to prepending
      } = config.guild_commands[{"guild1", "multi_guild"}]
      assert is_function(handler, 1)

      assert %{
        definition: %{name: "multi_guild", type: 1},
        handler: handler,
        guilds: ["guild2", "guild1"]
      } = config.guild_commands[{"guild2", "multi_guild"}]
      assert is_function(handler, 1)

      # Test command with options
      echo_command = config.global_commands["echo"]
      assert %{
        definition: %{
          name: "echo",
          type: 1,
          options: [
            %{name: "message", type: 3, description: "The message to echo", required: true},
            %{name: "count", type: 4, description: "Number of times to repeat", required: false, min_value: 1, max_value: 10},
            %{name: "public", type: 5, description: "Whether to make the response public", required: false}
          ]
        }
      } = echo_command

      # Test autocomplete command
      autocomplete_command = config.global_commands["autocomplete_test"]
      assert %{
        definition: %{
          name: "autocomplete_test",
          type: 1,
          options: [
            %{name: "query", type: 3, description: "Search query", required: true, autocomplete: true}
          ]
        },
        autocomplete_handler: handle_autocomplete
      } = autocomplete_command
      assert is_function(handle_autocomplete, 1)

      # Test handlers
      assert is_function(config.message_component_handler, 1)
      assert is_function(config.modal_submit_handler, 1)
    end
  end

  describe "option macro" do
    test "creates options with all supported types" do
      defmodule OptionTestHandler do
        use DiscordInteractions

        interactions do
          application_command "option_test", :chat_input do
            description("Test all option types")

            option("sub_command", :sub_command, description: "A sub command")
            option("sub_command_group", :sub_command_group, description: "A sub command group")
            option("string_opt", :string, description: "String option")
            option("integer_opt", :integer, description: "Integer option")
            option("boolean_opt", :boolean, description: "Boolean option")
            option("user_opt", :user, description: "User option")
            option("channel_opt", :channel, description: "Channel option")
            option("role_opt", :role, description: "Role option")
            option("mentionable_opt", :mentionable, description: "Mentionable option")
            option("number_opt", :number, description: "Number option")
            option("attachment_opt", :attachment, description: "Attachment option")

            handler(&option_test_command/1)
          end
        end

        def option_test_command(_interaction) do
          {:ok, %{type: 4, data: %{content: "Option test response"}}}
        end
      end

      config = OptionTestHandler.init()
      command = config.global_commands["option_test"]

      expected_options = [
        %{name: "sub_command", type: 1, description: "A sub command", required: false},
        %{name: "sub_command_group", type: 2, description: "A sub command group", required: false},
        %{name: "string_opt", type: 3, description: "String option", required: false},
        %{name: "integer_opt", type: 4, description: "Integer option", required: false},
        %{name: "boolean_opt", type: 5, description: "Boolean option", required: false},
        %{name: "user_opt", type: 6, description: "User option", required: false},
        %{name: "channel_opt", type: 7, description: "Channel option", required: false},
        %{name: "role_opt", type: 8, description: "Role option", required: false},
        %{name: "mentionable_opt", type: 9, description: "Mentionable option", required: false},
        %{name: "number_opt", type: 10, description: "Number option", required: false},
        %{name: "attachment_opt", type: 11, description: "Attachment option", required: false}
      ]

      assert command.definition.options == expected_options
    end

    test "creates options with choices" do
      defmodule ChoicesTestHandler do
        use DiscordInteractions

        interactions do
          application_command "choices_test", :chat_input do
            description("Test choices")

            option("choice_opt", :string,
              description: "Option with choices",
              choices: [
                %{name: "Option 1", value: "opt1"},
                %{name: "Option 2", value: "opt2"}
              ]
            )

            handler(&choices_test_command/1)
          end
        end

        def choices_test_command(_interaction) do
          {:ok, %{type: 4, data: %{content: "Choices test response"}}}
        end
      end

      config = ChoicesTestHandler.init()
      command = config.global_commands["choices_test"]

      # Just check that the option has the right structure and choices are present
      assert [option] = command.definition.options
      assert option.name == "choice_opt"
      assert option.type == 3
      assert option.description == "Option with choices"
      assert option.required == false
      assert is_list(option.choices)
      assert length(option.choices) == 2
    end
  end

  describe "error handling" do
    test "raises error for invalid command type" do
      assert_raise RuntimeError, "Invalid command type: :invalid", fn ->
        defmodule InvalidCommandTypeHandler do
          use DiscordInteractions

          interactions do
            application_command "test", :invalid do
              description("Invalid command")
              handler(&test_command/1)
            end
          end

          def test_command(_interaction), do: {:ok, %{type: 4}}
        end
      end
    end

    test "raises error for invalid option type" do
      assert_raise RuntimeError, "Invalid option type: :invalid", fn ->
        defmodule InvalidOptionTypeHandler do
          use DiscordInteractions

          interactions do
            application_command "test", :chat_input do
              description("Test command")
              option("invalid", :invalid, description: "Invalid option")
              handler(&test_command/1)
            end
          end

          def test_command(_interaction), do: {:ok, %{type: 4}}
        end
      end
    end

    test "accepts integer command types" do
      defmodule IntegerCommandTypeHandler do
        use DiscordInteractions

        interactions do
          application_command "test", 1 do
            description("Test command with integer type")
            handler(&test_command/1)
          end
        end

        def test_command(_interaction) do
          {:ok, %{type: 4, data: %{content: "Integer type response"}}}
        end
      end

      config = IntegerCommandTypeHandler.init()
      command = config.global_commands["test"]
      assert command.definition.type == 1
    end

    test "accepts integer option types" do
      defmodule IntegerOptionTypeHandler do
        use DiscordInteractions

        interactions do
          application_command "test", :chat_input do
            description("Test command")
            option("test_opt", 3, description: "Test option with integer type")
            handler(&test_command/1)
          end
        end

        def test_command(_interaction), do: {:ok, %{type: 4}}
      end

      config = IntegerOptionTypeHandler.init()
      command = config.global_commands["test"]
      assert [%{type: 3}] = command.definition.options
    end
  end

  describe "edge cases" do
    test "handles commands without guild_id in interaction" do
      # Test global command without guild_id
      interaction = %{
        "type" => 2,
        "data" => %{"name" => "test"}
      }

      # This should still work for global commands
      assert {:ok, %{type: 4, data: %{content: "Test response"}}} = TestHandler.handle(interaction)
    end

    test "handles empty interactions block" do
      defmodule EmptyHandler do
        use DiscordInteractions

        interactions do
          # Empty block
        end
      end

      config = EmptyHandler.init()
      assert config.global_commands == %{}
      assert config.guild_commands == %{}
      assert config.message_component_handler == nil
      assert config.modal_submit_handler == nil
    end

    test "handles commands without descriptions" do
      defmodule NoDescriptionHandler do
        use DiscordInteractions

        interactions do
          application_command "no_desc", :user do
            handler(&no_desc_command/1)
          end
        end

        def no_desc_command(_interaction) do
          {:ok, %{type: 4, data: %{content: "No description response"}}}
        end
      end

      config = NoDescriptionHandler.init()
      command = config.global_commands["no_desc"]
      assert command.definition.type == 2  # User command type
      refute Map.has_key?(command.definition, :description)
    end

    test "handles options with channel_types" do
      defmodule ChannelTypesHandler do
        use DiscordInteractions

        interactions do
          application_command "channel_test", :chat_input do
            description("Test channel types")

            option("channel", :channel,
              description: "Channel option",
              channel_types: [:guild_text, :guild_voice, :guild_category]
            )

            handler(&channel_test_command/1)
          end
        end

        def channel_test_command(_interaction), do: {:ok, %{type: 4}}
      end

      config = ChannelTypesHandler.init()
      command = config.global_commands["channel_test"]

      expected_option = %{
        name: "channel",
        type: 7,
        description: "Channel option",
        required: false,
        channel_types: [0, 2, 4]  # Converted from atoms to integers
      }

      assert [^expected_option] = command.definition.options
    end

    test "handles unknown interaction types" do
      # Test unknown interaction type
      interaction = %{
        "type" => 999,
        "data" => %{"name" => "test"}
      }

      assert :error = TestHandler.handle(interaction)
    end
  end
end
