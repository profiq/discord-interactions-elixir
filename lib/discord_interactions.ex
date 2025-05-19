defmodule DiscordInteractions do
  @moduledoc """
  Discord Interactions is a library for handling Discord slash commands and other interaction types in Elixir applications.

  ## Configuration

  Add the library to your dependencies in `mix.exs`:

  ```elixir
  def deps do
    [
      {:discord_interactions, "~> 0.1.0"}
    ]
  end
  ```

  Configure the library in your `config/runtime.exs` or `config/config.exs`:

  ```elixir
  config :discord_interactions,
    public_key: System.get_env("DISCORD_PUBLIC_KEY"),
    bot_token: System.get_env("DISCORD_BOT_TOKEN"),
    application_id: System.get_env("DISCORD_APPLICATION_ID")
  ```

  You'll need to obtain these values from the Discord Developer Portal:
  - `DISCORD_PUBLIC_KEY`: Found in your application's "General Information" section
  - `DISCORD_BOT_TOKEN`: Found in your application's "Bot" section
  - `DISCORD_APPLICATION_ID`: Your application's ID found in the "General Information" section

  ## Integration

  ### 1. Create a Command Handler Module

  Create a module that will handle your Discord interactions:

  ```elixir
  defmodule YourApp.Discord do
    use DiscordInteractions

    # Define your interactions here
    interactions do
      # Commands will go here
    end

    # Command handler functions will go here
  end
  ```

  ### 2. Add the Plug to Your Router

  In your Phoenix router, add the Discord Interactions plug:

  ```elixir
  defmodule YourAppWeb.Router do
    use YourAppWeb, :router

    # Other pipelines and routes...

    # Route for Discord interactions
    forward "/discord", DiscordInteractions.Plug, YourApp.Discord
  end
  ```

  ### 3. Configure Your Endpoint

  The plug expects the raw request body to be available under `conn.assigns[:raw_body]` for signature verification. You can use the provided `CacheBodyReader` to achiveve this:

  ```elixir
  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library(),
    body_reader: {DiscordInteractions.CacheBodyReader, :read_body, []}
  ```

  ### 4. Add Command Registration to Your Application Supervisor

  The `DiscordInteractions.CommandRegistration` task registers the commands defined in your handler module with Discord. Add it to your application's supervision tree:

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

  ## Implementing Command Handlers

  ### Defining Commands

  Use the DSL to define your commands in the `interactions` block. The library provides macros for common command properties, but you can also use the `properties/1` macro to access any Discord API feature, even those not explicitly implemented in the library.

  You can define both global commands (available in all servers where your bot is installed) and guild-specific commands (available only in specific servers). Guild commands are useful for testing, server-specific features, or commands that should only be available to certain communities. Guild commands update instantly, unlike global commands which can take up to an hour to propagate.

  ```elixir
  interactions do
    # Simple command without options
    application_command "hello" do
      description("A friendly greeting command")
      handler(&hello_command/1)
    end

    # Command with options
    application_command "echo" do
      description("Repeats your message")

      # Add a required string option
      option("message", :string,
        description: "The message to echo back",
        required: true
      )

      handler(&echo_command/1)
    end

    # Command with multiple options of different types
    application_command "profile" do
      description("Set your profile information")

      option("name", :string,
        description: "Your display name",
        required: true
      )

      option("age", :integer,
        description: "Your age",
        min_value: 13,
        max_value: 120
      )

      option("favorite_color", :string,
        description: "Your favorite color",
        choices: [
          %{name: "Red", value: "red"},
          %{name: "Green", value: "green"},
          %{name: "Blue", value: "blue"}
        ]
      )

      handler(&profile_command/1)
    end

    # User context menu command (appears when right-clicking a user)
    application_command "View Profile", :user do
      # User commands don't need a description
      handler(&view_profile_command/1)
    end

    # Message context menu command (appears when right-clicking a message)
    application_command "Translate", :message do
      # Message commands don't need a description
      handler(&translate_message_command/1)
    end

    # Guild-specific command (only available in specific servers)
    application_command "test" do
      description("Test command for development")
      guild("123456789012345678")  # Available in this guild
      guild("876543210987654321")  # And also in this guild
      handler(&test_command/1)
    end

    # Handle component interactions (buttons, select menus)
    message_component_handler(&handle_component/1)

    # Handle modal submissions
    modal_submit_handler(&handle_modal/1)
  end
  ```

  ### Implementing Handler Functions

  Handler functions receive the raw Discord interaction object and should return a response. The interaction object contains all the data sent by Discord, including command options, user information, and more.

  Implement the handler functions referenced in your command definitions using the `DiscordInteractions.InteractionResponse` module to create responses:

  ```elixir
  alias DiscordInteractions.InteractionResponse

  # Simple command handler
  def hello_command(interaction) do
    # Access user information from the interaction
    user = get_in(interaction, ["member", "user", "username"])

    response = InteractionResponse.channel_message_with_source()
               |> InteractionResponse.content("Hello, " <> user)

    {:ok, response}
  end

  # Command handler with a single option
  def echo_command(interaction) do
    # Extract option values from the interaction
    options = get_in(interaction, ["data", "options"])

    # Find the value of the "message" option
    message = Enum.find_value(options, "", fn opt ->
      if opt["name"] == "message", do: opt["value"], else: nil
    end)

    response = InteractionResponse.channel_message_with_source()
               |> InteractionResponse.content("Echo: " <> message)

    {:ok, response}
  end

  # Command handler with multiple options
  def profile_command(interaction) do
    # Extract all options from the interaction
    options = get_in(interaction, ["data", "options"])

    # Extract each option value
    name = Enum.find_value(options, "", fn opt ->
      if opt["name"] == "name", do: opt["value"], else: nil
    end)

    # Integer options are returned as numbers
    age = Enum.find_value(options, nil, fn opt ->
      if opt["name"] == "age", do: opt["value"], else: nil
    end)

    # Options with choices return the value, not the name
    favorite_color = Enum.find_value(options, nil, fn opt ->
      if opt["name"] == "favorite_color", do: opt["value"], else: nil
    end)

    # Build a response with all the profile information
    age_text = if age, do: Integer.to_string(age), else: "not specified"
    color_text = if favorite_color, do: favorite_color, else: "not specified"

    response = InteractionResponse.channel_message_with_source()
               |> InteractionResponse.content("Profile set!\nName: " <> name <>
                                             "\nAge: " <> age_text <>
                                             "\nFavorite Color: " <> color_text)

    {:ok, response}
  end

  # User context menu command handler
  def view_profile_command(interaction) do
    # For user commands, the target user ID is in the data.target_id field
    user_id = get_in(interaction, ["data", "target_id"])

    # You can access information about the user who triggered the command
    commander_name = get_in(interaction, ["member", "user", "username"])

    # Create a response with information about the user
    response = InteractionResponse.channel_message_with_source()
               |> InteractionResponse.content(commander_name <> " is viewing the profile of user ID: " <> user_id <>
                                             "\n\nIn a real application, you would fetch and display user information here.")

    {:ok, response}
  end

  # Message context menu command handler
  def translate_message_command(interaction) do
    # For message commands, the target message ID is in the data.target_id field
    message_id = get_in(interaction, ["data", "target_id"])

    # In a real application, you would fetch the message content and translate it
    # For this example, we'll just acknowledge that we received the command
    response = InteractionResponse.channel_message_with_source()
               |> InteractionResponse.content("Translating message ID: " <> message_id <>
                                             "\n\nIn a real application, you would fetch the message content and translate it.")

    {:ok, response}
  end

  # Handler for a command available in multiple guilds
  def test_command(interaction) do
    # Get guild information
    guild_id = get_in(interaction, ["guild_id"])
    user = get_in(interaction, ["member", "user", "username"])

    # Guild commands are useful for testing features before making them global
    # They update instantly, unlike global commands which can take up to an hour
    response = InteractionResponse.channel_message_with_source()
               |> InteractionResponse.content("Test command executed by " <> user <> " in guild " <> guild_id <> "!\n" <>
                                             "Guild commands are perfect for testing and server-specific features.")

    {:ok, response}
  end

  # Component handler with pattern matching on custom_id
  def handle_component(%{"data" => %{"custom_id" => "button_1"}} = interaction) do
    # Access user information from the interaction
    user = get_in(interaction, ["member", "user", "username"])

    response = InteractionResponse.channel_message_with_source()
               |> InteractionResponse.content(user <> " clicked button 1!")

    {:ok, response}
  end

  def handle_component(%{"data" => %{"custom_id" => "button_2"}} = interaction) do
    response = InteractionResponse.channel_message_with_source()
               |> InteractionResponse.content("You clicked the danger button!")

    {:ok, response}
  end
  ```

  ### Response Types

  Handler functions should return one of:

  - `{:ok, response}` - Successful response with data.
  - `:ok` - Sends a `202 Accepted` response to the initial request. Use this if you want to send the interaction response manually using the Discord API. Note that the three second timeout still applies in this case.

  ### Using Helper Modules for Responses

  The library provides helper modules to construct responses more easily. Use the `DiscordInteractions.InteractionResponse` module together with the `DiscordInteractions.Components` module:

  ```elixir
  alias DiscordInteractions.InteractionResponse
  import DiscordInteractions.Components

  def button_command(_interaction) do
    # Create action row with buttons
    buttons_row = action_row(
      components: [
        button(
          style: :primary,
          label: "Click Me",
          custom_id: "button_1"
        ),
        button(
          style: :danger,
          label: "Danger",
          custom_id: "button_2"
        )
      ]
    )

    # Create the response with content and components
    response = InteractionResponse.channel_message_with_source()
               |> InteractionResponse.content("Here are some buttons:")
               |> InteractionResponse.components([buttons_row])

    {:ok, response}
  end
  ```



  ## Advanced Usage

  ### Command Options and Properties

  Command properties are raw Discord API structures that follow the [Discord API documentation](https://discord.com/developers/docs/interactions/application-commands). When using the `properties/1` macro, you're directly providing the JSON structure that Discord expects.

  The `properties/1` macro is particularly useful for accessing Discord API features that aren't explicitly implemented in the library. You can use it to define any command option or property supported by Discord's API, even if there isn't a specific macro for it in this library.

  You can define complex commands with options using the `option` macro:

  ```elixir
  application_command "echo" do
    description("Repeats your message")

    # Add a required string option
    option("message", :string,
      description: "The message to echo back",
      required: true
    )

    handler(&echo_command/1)
  end
  ```

  The `option` macro supports all Discord option types:
  - `:sub_command` - A sub-command
  - `:sub_command_group` - A group of sub-commands
  - `:string` - A string value
  - `:integer` - An integer value
  - `:boolean` - A boolean value
  - `:user` - A Discord user
  - `:channel` - A Discord channel
  - `:role` - A Discord role
  - `:mentionable` - A mentionable entity (user, role, etc.)
  - `:number` - A floating-point number
  - `:attachment` - A file attachment

  You can also use the raw `properties` macro for more complex scenarios:

  ```elixir
  application_command "echo" do
    description("Repeats your message")

    # This is a raw Discord API structure following their documentation
    properties(%{
      type: 1,  # CHAT_INPUT
      options: [
        %{
          type: 3,  # STRING
          name: "message",
          description: "The message to echo back",
          required: true
        }
      ]
    })

    handler(&echo_command/1)
  end
  ```

  When handling commands with options, you can access the options from the interaction data:

  ```elixir
  alias DiscordInteractions.InteractionResponse

  def echo_command(interaction) do
    # Extract the option value from the interaction
    options = interaction["data"]["options"]
    message = Enum.find_value(options, "", fn opt ->
      if opt["name"] == "message", do: opt["value"], else: nil
    end)

    # Create response using the InteractionResponse module
    response = InteractionResponse.channel_message_with_source()
               |> InteractionResponse.content("Echo: " <> message)

    {:ok, response}
  end
  ```

  ### Autocomplete Commands

  You can create commands with autocomplete options to provide dynamic suggestions as users type:

  ```elixir
  application_command "search" do
    description("Search for items")

    # Define command option with autocomplete
    option("query", :string,
      description: "Search term",
      autocomplete: true
    )

    # Set the main command handler
    handler(&search_command/1)

    # Set the autocomplete handler for this command
    autocomplete_handler(&search_autocomplete/1)
  end
  ```

  Implement the autocomplete handler to provide suggestions as the user types:

  ```elixir
  alias DiscordInteractions.InteractionResponse

  def search_autocomplete(interaction) do
    # Get the current input value
    focused_option = Enum.find(
      interaction["data"]["options"],
      fn opt -> opt["focused"] == true end
    )
    current_input = focused_option["value"]

    # Generate suggestions based on the current input
    suggestions =
      case current_input do
        "a" <> _ -> [
          InteractionResponse.choice("Apple", "apple"),
          InteractionResponse.choice("Apricot", "apricot"),
          InteractionResponse.choice("Avocado", "avocado")
        ]
        "b" <> _ -> [
          InteractionResponse.choice("Banana", "banana"),
          InteractionResponse.choice("Blueberry", "blueberry"),
          InteractionResponse.choice("Blackberry", "blackberry")
        ]
        _ -> [
          InteractionResponse.choice("Apple", "apple"),
          InteractionResponse.choice("Banana", "banana"),
          InteractionResponse.choice("Cherry", "cherry")
        ]
      end

    # Return autocomplete suggestions
    response = InteractionResponse.application_command_autocomplete_result(suggestions)
    {:ok, response}
  end
  ```
  """

  @type guild :: String.t()

  @type command :: %{
          definition: map(),
          handler: function() | nil,
          autocomplete_handler: function() | nil,
          guilds: list(String.t())
        }

  @type config :: %{
          global_commands: %{String.t() => command},
          guild_commands: %{{guild, String.t()} => command},
          message_component_handler: function() | nil,
          modal_submit_handler: function() | nil
        }

  # Interaction types
  @application_command 2
  @message_component 3
  @application_command_autocomplete 4
  @modal_submit 5

  # Application command types
  @chat_input 1
  @user 2
  @message 3

  # Application command option types
  @option_sub_command 1
  @option_sub_command_group 2
  @option_string 3
  @option_integer 4
  @option_boolean 5
  @option_user 6
  @option_channel 7
  @option_role 8
  @option_mentionable 9
  @option_number 10
  @option_attachment 11

  # Import utilities
  alias DiscordInteractions.Util

  @doc """
  Defines a block for declaring Discord interactions.

  This macro is the entry point for defining commands, handlers, and other interaction-related
  configurations. It should be used within a module that uses `DiscordInteractions`.

  ## Example

  ```elixir
  defmodule MyApp.Discord do
    use DiscordInteractions

    interactions do
      # Define commands and handlers here

      # Slash command (chat input)
      application_command "hello", :chat_input do
        description("A friendly greeting command")
        handler(&hello_command/1)
      end

      # User context menu command
      application_command "Get Avatar", :user do
        handler(&get_avatar_command/1)
      end

      # Message context menu command
      application_command "Translate", :message do
        handler(&translate_message_command/1)
      end

      message_component_handler(&handle_component/1)
    end

    # Implement handler functions here
    def hello_command(_interaction) do
      # ...
    end

    def get_avatar_command(_interaction) do
      # ...
    end

    def translate_message_command(_interaction) do
      # ...
    end
  end
  ```
  """
  defmacro interactions(do: block) do
    quote do
      @spec init() :: DiscordInteractions.config()
      def init do
        var!(interactions) = %{
          global_commands: %{},
          guild_commands: %{},
          message_component_handler: nil,
          modal_submit_handler: nil
        }

        unquote(block)
        var!(interactions)
      end
    end
  end

  @doc """
  Defines a Discord application command.

  This macro creates a new application command with the given name and allows you to configure
  it using other macros within its block.

  ## Parameters
  - `name` - The name of the command (used as the command name in Discord)
  - `type` - The type of command (`:chat_input`, `:user`, or `:message`), defaults to `:chat_input`
  - `opts` - Additional options (reserved for future use)
  - `block` - A block containing command configuration

  ## Command Types
  - `:chat_input` - Slash commands that show up when a user types /
  - `:user` - Commands that appear in the context menu for users
  - `:message` - Commands that appear in the context menu for messages

  ## Example

  ```elixir
  # Chat input command (slash command)
  application_command "hello", :chat_input do
    description("A friendly greeting command")
    handler(&hello_command/1)
  end

  # User context menu command
  application_command "Get User Info", :user do
    handler(&user_info_command/1)
  end

  # Message context menu command
  application_command "Translate", :message do
    handler(&translate_message_command/1)
  end

  # Guild-specific command
  application_command "admin", :chat_input do
    description("Admin-only command")
    guild("123456789012345678")  # Specific to this guild
    handler(&admin_command/1)
  end

  # Command with options (only valid for chat_input type)
  application_command "echo", :chat_input do
    description("Repeats your message")

    option("message", :string,
      description: "The message to echo back",
      required: true
    )

    handler(&echo_command/1)
  end
  ```

  Note: Description and options are only valid for `:chat_input` commands. User and message
  commands don't support descriptions or options.
  """
  defmacro application_command(name, type \\ :chat_input, _opts \\ [], do: block) do
    # Convert command type to integer
    command_type = case type do
      :chat_input -> @chat_input
      :user -> @user
      :message -> @message
      _ when is_integer(type) -> type
      _ -> raise "Invalid command type: #{inspect(type)}"
    end

    quote do
      var!(command) = %{
        definition: %{
          name: unquote(name),
          type: unquote(command_type)
        },
        handler: nil,
        autocomplete_handler: nil,
        guilds: []
      }

      unquote(block)

      var!(interactions) =
        if var!(command).guilds == [] do
          %{
            var!(interactions)
            | global_commands:
                Map.put(var!(interactions).global_commands, unquote(name), var!(command))
          }
        else
          %{
            var!(interactions)
            | guild_commands:
                var!(command).guilds
                |> Enum.reduce(%{}, fn guild, acc ->
                  Map.put(acc, {guild, unquote(name)}, var!(command))
                end)
                |> Map.merge(var!(interactions).guild_commands)
          }
        end
    end
  end

  @doc """
  Sets the name of a command.

  This macro is used within an `application_command` block to set or change the command's name.

  ## Parameters
  - `name` - The name of the command

  ## Example

  ```elixir
  application_command "initial_name" do
    # Override the name
    name("actual_name")
    description("A command with a different name")
    handler(&my_command/1)
  end
  ```

  Note: In most cases, it's simpler to set the name directly in the `application_command` macro.
  """
  defmacro name(name) do
    quote do
      var!(command) = %{
        var!(command)
        | definition: Map.put(var!(command).definition, :name, unquote(name))
      }
    end
  end

  @doc """
  Sets the description of a command.

  This macro is used within an `application_command` block to set the command's description,
  which is displayed in the Discord UI.

  ## Parameters
  - `description` - The description text for the command

  ## Example

  ```elixir
  application_command "hello" do
    description("A friendly greeting command")
    handler(&hello_command/1)
  end
  ```
  """
  defmacro description(description) do
    quote do
      var!(command) = %{
        var!(command)
        | definition: Map.put(var!(command).definition, :description, unquote(description))
      }
    end
  end

  @doc """
  Sets raw properties for a command.

  This macro allows you to directly set properties on a command using the raw Discord API format.
  It's useful for accessing Discord API features that aren't explicitly implemented in the library.

  ## Parameters
  - `properties` - A map of properties to merge with the command definition

  ## Example

  ```elixir
  application_command "advanced" do
    description("An advanced command")

    # Set raw properties following Discord's API documentation
    properties(%{
      type: 1,  # CHAT_INPUT
      default_member_permissions: "8",  # Administrator permission
      dm_permission: false,  # Disable in DMs
      nsfw: true  # Mark as NSFW
    })

    handler(&advanced_command/1)
  end
  ```
  """
  defmacro properties(properties) do
    quote do
      var!(command) = %{
        var!(command)
        | definition: Map.merge(var!(command).definition, unquote(properties))
      }
    end
  end

  @doc """
  Specifies that a command should be registered to a specific guild (server).

  By default, commands are registered globally across all servers. This macro restricts
  a command to only be available in the specified guild.

  ## Parameters
  - `guild` - The Discord guild (server) ID where the command should be available

  ## Example

  ```elixir
  application_command "admin" do
    description("Admin-only command")
    guild("123456789012345678")  # Specific to this guild
    handler(&admin_command/1)
  end
  ```

  You can also make a command available in multiple guilds by calling this macro multiple times:

  ```elixir
  application_command "test" do
    description("Test command")
    guild("123456789012345678")  # Available in this guild
    guild("876543210987654321")  # And also in this guild
    handler(&test_command/1)
  end
  ```
  """
  defmacro guild(guild) do
    quote do
      var!(command) = %{var!(command) | guilds: [unquote(guild) | var!(command).guilds]}
    end
  end

  @doc """
  Sets the handler function for a command.

  This macro specifies which function should be called when a user invokes the command.
  The handler function receives the interaction data and should return a response.

  ## Parameters
  - `handler` - Function reference to handle the command

  ## Example

  ```elixir
  application_command "hello" do
    description("A friendly greeting command")
    handler(&hello_command/1)
  end

  def hello_command(interaction) do
    response = InteractionResponse.channel_message_with_source()
               |> InteractionResponse.content("Hello, world!")

    {:ok, response}
  end
  ```

  Handler functions should return one of:
  - `{:ok, response}` - Successful response with data
  - `:ok` - Success with no response data (202 Accepted)
  """
  defmacro handler(handler) do
    quote do
      var!(command) = %{var!(command) | handler: unquote(handler)}
    end
  end

  @doc """
  Sets the handler function for message component interactions.

  This macro specifies which function should be called when a user interacts with
  message components like buttons or select menus.

  ## Parameters
  - `handler` - Function reference to handle component interactions

  ## Example

  ```elixir
  interactions do
    # Define commands...

    # Set the component handler
    message_component_handler(&handle_component/1)
  end

  # Component handler with pattern matching on custom_id
  def handle_component(%{"data" => %{"custom_id" => "button_1"}} = interaction) do
    response = InteractionResponse.channel_message_with_source()
               |> InteractionResponse.content("You clicked button 1!")

    {:ok, response}
  end

  def handle_component(%{"data" => %{"custom_id" => "button_2"}} = interaction) do
    response = InteractionResponse.channel_message_with_source()
               |> InteractionResponse.content("You clicked button 2!")

    {:ok, response}
  end

  # Fallback for unhandled custom_ids
  def handle_component(_interaction) do
    :error
  end
  ```
  """
  defmacro message_component_handler(handler) do
    quote do
      var!(interactions) = %{var!(interactions) | message_component_handler: unquote(handler)}
    end
  end

  @doc """
  Sets the handler function for modal submissions.

  This macro specifies which function should be called when a user submits a modal form.

  ## Parameters
  - `handler` - Function reference to handle modal submissions

  ## Example

  ```elixir
  interactions do
    # Define commands...

    # Set the modal submission handler
    modal_submit_handler(&handle_modal/1)
  end

  # Modal handler with pattern matching on custom_id
  def handle_modal(%{"data" => %{"custom_id" => "feedback_form"}} = interaction) do
    # Extract values from the modal components
    components = get_in(interaction, ["data", "components"])

    feedback = Enum.find_value(components, "", fn component ->
      text_inputs = component["components"]

      Enum.find_value(text_inputs, "", fn input ->
        if input["custom_id"] == "feedback_input", do: input["value"], else: nil
      end)
    end)

    # Create a response
    response = InteractionResponse.channel_message_with_source()
               |> InteractionResponse.content("Thank you for your feedback: \#{feedback}")

    {:ok, response}
  end

  # Fallback for unhandled modal submissions
  def handle_modal(_interaction) do
    :error
  end
  ```
  """
  defmacro modal_submit_handler(handler) do
    quote do
      var!(interactions) = %{var!(interactions) | modal_submit_handler: unquote(handler)}
    end
  end

  @doc """
  Sets the autocomplete handler function for a command.

  This handler will be called when a user is typing in an autocomplete option field.
  The handler should return suggestions based on the current input.

  ## Parameters
  - `handler` - Function reference to handle autocomplete requests

  ## Example

  ```elixir
  application_command "search" do
    description("Search for items")

    option("query", :string,
      description: "Search term",
      autocomplete: true
    )

    handler(&search_command/1)
    autocomplete_handler(&search_autocomplete/1)
  end

  def search_autocomplete(interaction) do
    # Get the current input value
    focused_option = Enum.find(
      interaction["data"]["options"],
      fn opt -> opt["focused"] == true end
    )
    current_input = focused_option["value"]

    # Generate suggestions based on the current input
    suggestions = [
      InteractionResponse.choice("Option 1", "option1"),
      InteractionResponse.choice("Option 2", "option2")
    ]

    # Return autocomplete suggestions
    response = InteractionResponse.application_command_autocomplete_result(suggestions)
    {:ok, response}
  end
  ```
  """
  defmacro autocomplete_handler(handler) do
    quote do
      var!(command) = %{var!(command) | autocomplete_handler: unquote(handler)}
    end
  end

  @doc """
  Adds an option to an application command.

  ## Parameters
  - `name` - The name of the option (used as the parameter name in Discord)
  - `type` - The type of the option (atom or integer)
  - `opts` - Additional option settings

  ## Option Types
  - `:sub_command` - A sub-command
  - `:sub_command_group` - A group of sub-commands
  - `:string` - A string value
  - `:integer` - An integer value
  - `:boolean` - A boolean value
  - `:user` - A Discord user
  - `:channel` - A Discord channel
  - `:role` - A Discord role
  - `:mentionable` - A mentionable entity (user, role, etc.)
  - `:number` - A floating-point number
  - `:attachment` - A file attachment

  ## Additional Options
  - `:description` - Description of the option (default: "")
  - `:required` - Whether the option is required (default: false)
  - `:choices` - List of choices for the option
  - `:min_value` - Minimum value for integer/number options
  - `:max_value` - Maximum value for integer/number options
  - `:autocomplete` - Whether the option supports autocomplete (default: false)
  - `:channel_types` - List of channel types for channel options

  ## Examples

  ```elixir
  # Basic string option
  option("message", :string, description: "The message to echo back", required: true)

  # Integer option with min/max values
  option("count", :integer,
    description: "Number of times to repeat",
    min_value: 1,
    max_value: 10,
    required: false
  )

  # String option with choices
  option("color", :string,
    description: "Choose a color",
    choices: [
      %{name: "Red", value: "red"},
      %{name: "Green", value: "green"},
      %{name: "Blue", value: "blue"}
    ]
  )

  # Channel option with specific channel types
  option("channel", :channel,
    description: "Select a text channel",
    channel_types: [:guild_text, :guild_announcement]  # Text and announcement channels
  )

  # String option with autocomplete
  option("query", :string,
    description: "Search term",
    autocomplete: true
  )
  ```
  """
  defmacro option(name, type, opts \\ []) do
    # Convert option type to integer
    option_type = case type do
      :sub_command -> @option_sub_command
      :sub_command_group -> @option_sub_command_group
      :string -> @option_string
      :integer -> @option_integer
      :boolean -> @option_boolean
      :user -> @option_user
      :channel -> @option_channel
      :role -> @option_role
      :mentionable -> @option_mentionable
      :number -> @option_number
      :attachment -> @option_attachment
      _ when is_integer(type) -> type
      _ -> raise "Invalid option type: #{inspect(type)}"
    end

    # Create the base option map
    new_option = %{
      name: name,
      type: option_type,
      description: Keyword.get(opts, :description, ""),
      required: Keyword.get(opts, :required, false)
    }

    # Add optional fields if they are provided
    new_option = if Keyword.has_key?(opts, :choices) do
      Map.put(new_option, :choices, Keyword.get(opts, :choices))
    else
      new_option
    end

    new_option = if Keyword.has_key?(opts, :min_value) do
      Map.put(new_option, :min_value, Keyword.get(opts, :min_value))
    else
      new_option
    end

    new_option = if Keyword.has_key?(opts, :max_value) do
      Map.put(new_option, :max_value, Keyword.get(opts, :max_value))
    else
      new_option
    end

    new_option = if Keyword.has_key?(opts, :autocomplete) do
      Map.put(new_option, :autocomplete, Keyword.get(opts, :autocomplete))
    else
      new_option
    end

    # Handle channel types with Util module
    new_option = if Keyword.has_key?(opts, :channel_types) do
      channel_types = Util.channel_types(Keyword.get(opts, :channel_types))
      Map.put(new_option, :channel_types, channel_types)
    else
      new_option
    end

    # Return the quoted code that will be inserted
    quote do
      # Get the current options list or initialize an empty one
      current_options = Map.get(var!(command).definition, :options, [])

      # Update the command definition with the new option
      # Append to the end of the list to maintain order
      var!(command) = %{
        var!(command)
        | definition: Map.put(
            var!(command).definition,
            :options,
            current_options ++ [unquote(Macro.escape(new_option))]
          )
      }
    end
  end

  defmacro __using__(_) do
    quote do
      @behaviour DiscordInteractions.CommandHandler

      import DiscordInteractions

      @spec handle(map()) :: map()
      def handle(
            %{
              "type" => unquote(@application_command),
              "data" => %{"name" => command_name},
              "guild_id" => guild_id
            } = itx
          ) do
        # Handle application command
        case init() do
          %{guild_commands: %{{^guild_id, ^command_name} => %{handler: handler}}}
          when not is_nil(handler) ->
            handler.(itx)

          %{global_commands: %{^command_name => %{handler: handler}}} when not is_nil(handler) ->
            handler.(itx)

          _ ->
            :error
        end
      end

      def handle(%{"type" => unquote(@message_component)} = itx) do
        # Handle message component
        case init() do
          %{message_component_handler: handler} when not is_nil(handler) ->
            handler.(itx)

          _ ->
            :error
        end
      end

      def handle(
            %{
              "type" => unquote(@application_command_autocomplete),
              "data" => %{"name" => command_name},
              "guild_id" => guild_id
            } = itx
          ) do
        # Handle application command autocomplete
        case init() do
          %{guild_commands: %{{^guild_id, ^command_name} => %{autocomplete_handler: handler}}}
          when not is_nil(handler) ->
            handler.(itx)

          %{global_commands: %{^command_name => %{autocomplete_handler: handler}}}
          when not is_nil(handler) ->
            handler.(itx)

          _ ->
            :error
        end
      end

      def handle(%{"type" => unquote(@modal_submit)} = itx) do
        # Handle modal submit
        case init() do
          %{modal_submit_handler: handler} when not is_nil(handler) ->
            handler.(itx)

          _ ->
            :error
        end
      end
    end
  end
end
