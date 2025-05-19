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

  Use the DSL to define your commands in the `interactions` block. The library provides macros for common command properties, but you can also use the `properties/1` macro to access any Discord API feature, even those not explicitly implemented in the library:

  ```elixir
  interactions do
    # Global command
    application_command "hello" do
      description("A friendly greeting command")
      handler(&hello_command/1)
    end

    # Guild-specific command
    application_command "admin" do
      description("Admin-only command")
      guild("YOUR_GUILD_ID")  # Specific to this guild
      handler(&admin_command/1)
    end

    # Handle component interactions (buttons, select menus)
    message_component_handler(&handle_component/1)

    # Handle modal submissions
    modal_submit_handler(&handle_modal/1)
  end
  ```

  ### Implementing Handler Functions

  Implement the handler functions referenced in your command definitions using the `DiscordInteractions.InteractionResponse` module to create responses:

  ```elixir
  alias DiscordInteractions.InteractionResponse

  # Command handler
  def hello_command(_interaction) do
    response = InteractionResponse.channel_message_with_source()
               |> InteractionResponse.content("Hello, world!")

    {:ok, response}
  end

  # Component handler with pattern matching on custom_id
  def handle_component(%{"data" => %{"custom_id" => "button_1"}} = _interaction) do
    response = InteractionResponse.channel_message_with_source()
               |> InteractionResponse.content("You clicked button 1!")

    {:ok, response}
  end

  def handle_component(%{"data" => %{"custom_id" => "button_2"}} = _interaction) do
    response = InteractionResponse.channel_message_with_source()
               |> InteractionResponse.content("You clicked the danger button!")

    {:ok, response}
  end

  # Fallback for unhandled custom_ids
  def handle_component(_interaction) do
    :error
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

  You can define complex commands with options:

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

    # Define command options with autocomplete
    properties(%{
      options: [
        %{
          type: 3,  # STRING
          name: "query",
          description: "Search term",
          autocomplete: true  # Enable autocomplete for this option
        }
      ]
    })

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

  @application_command 2
  @message_component 3
  @application_command_autocomplete 4
  @modal_submit 5

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

  defmacro application_command(name, _opts \\ [], do: block) do
    quote do
      var!(command) = %{
        definition: %{name: unquote(name)},
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

  defmacro name(name) do
    quote do
      var!(command) = %{
        var!(command)
        | definition: Map.put(var!(command).definition, :name, unquote(name))
      }
    end
  end

  defmacro description(description) do
    quote do
      var!(command) = %{
        var!(command)
        | definition: Map.put(var!(command).definition, :description, unquote(description))
      }
    end
  end

  defmacro properties(properties) do
    quote do
      var!(command) = %{
        var!(command)
        | definition: Map.merge(var!(command).definition, unquote(properties))
      }
    end
  end

  defmacro guild(guild) do
    quote do
      var!(command) = %{var!(command) | guilds: [unquote(guild) | var!(command).guilds]}
    end
  end

  defmacro handler(handler) do
    quote do
      var!(command) = %{var!(command) | handler: unquote(handler)}
    end
  end

  defmacro message_component_handler(handler) do
    quote do
      var!(interactions) = %{var!(interactions) | message_component_handler: unquote(handler)}
    end
  end

  defmacro modal_submit_handler(handler) do
    quote do
      var!(interactions) = %{var!(interactions) | modal_submit_handler: unquote(handler)}
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
