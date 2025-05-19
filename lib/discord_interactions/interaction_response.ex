defmodule DiscordInteractions.InteractionResponse do
  @moduledoc """
  Provides functions for creating and manipulating Discord interaction responses.

  This module implements the Discord Interaction Response API as documented at:
  https://discord.com/developers/docs/interactions/receiving-and-responding

  It includes functions for creating different types of responses (like messages, modals, etc.)
  and modifying their properties (content, embeds, flags, etc.).

  ## Examples

      # Create a simple message response
      response = DiscordInteractions.InteractionResponse.channel_message_with_source()
                 |> DiscordInteractions.InteractionResponse.content("Hello, world!")

      # Create an ephemeral message (only visible to the user who triggered the interaction)
      response = DiscordInteractions.InteractionResponse.channel_message_with_source()
                 |> DiscordInteractions.InteractionResponse.content("This is a secret message")
                 |> DiscordInteractions.InteractionResponse.ephemeral()

      # Create a message with an embed
      alias DiscordInteractions.Embed

      embed = Embed.new()
              |> Embed.title("Hello, World!")
              |> Embed.description("This is an embed description")
              |> Embed.color(0x00FF00)
              |> Embed.add_field("Field 1", "Value 1", true)
              |> Embed.add_field("Field 2", "Value 2", true)

      response = DiscordInteractions.InteractionResponse.channel_message_with_source()
                 |> DiscordInteractions.InteractionResponse.embeds([embed])

      # Create a modal response
      response = DiscordInteractions.InteractionResponse.modal()
                 |> DiscordInteractions.InteractionResponse.title("My Modal")
                 |> DiscordInteractions.InteractionResponse.custom_id("my_modal")
                 |> DiscordInteractions.InteractionResponse.components([...])
  """

  import Bitwise

  alias DiscordInteractions.Components

  # Interaction response types
  @pong 1
  @channel_message_with_source 4
  @deferred_channel_message_with_source 5
  @deferred_update_message 6
  @update_message 7
  @application_command_autocomplete_result 8
  @modal 9
  @premium_required 10
  @launch_activity 12

  # Message flags
  @suppress_embeds 2
  @ephemeral 64
  @suppress_notifications 4_096
  @is_components_v2 32_768

  @typedoc """
  Represents a message response with optional fields.

  ## Fields
  - `tts`: Whether the message should be read aloud by Discord
  - `content`: The text content of the message
  - `embeds`: Array of embed objects
  - `allowed_mentions`: Controls which mentions are allowed in the message
  - `flags`: Message flags (like ephemeral, suppress_embeds, etc.)
  - `components`: Array of message components (buttons, select menus, etc.)
  - `attachments`: Array of attachment objects
  - `poll`: Poll object for creating polls
  """
  @type message :: %{
          optional(:tts) => boolean(),
          optional(:content) => String.t(),
          optional(:embeds) => [map()],
          optional(:allowed_mentions) => map(),
          optional(:flags) => integer(),
          optional(:components) => [Components.component()],
          optional(:attachments) => [map()],
          optional(:poll) => map()
        }

  @typedoc """
  Represents a choice for autocomplete suggestions.

  ## Fields
  - `name`: The display name of the choice shown to users
  - `value`: The value of the choice sent to your application when selected
  - `name_localizations`: Optional map of localized names for different languages
  """
  @type choice :: %{
          optional(:name_localizations) => map(),
          optional(:name) => String.t(),
          optional(:value) => any()
        }

  @typedoc """
  Represents an autocomplete response with choices.

  ## Fields
  - `choices`: Array of choice objects for autocomplete suggestions
  """
  @type autocomplete :: %{
          optional(:choices) => [choice()]
        }

  @typedoc """
  Represents a modal response.

  ## Fields
  - `title`: The title of the modal
  - `custom_id`: A developer-defined identifier for the modal
  - `components`: Array of components to include in the modal
  """
  @type modal :: %{
          optional(:title) => String.t(),
          optional(:custom_id) => String.t(),
          optional(:components) => [Components.component()]
        }

  @typedoc """
  Represents a complete interaction response.

  ## Fields
  - `type`: The type of response (numeric value)
  - `data`: The data for the response, which varies based on the type
  """
  @type t :: %{
          optional(:data) => message() | autocomplete() | modal(),
          type: integer()
        }

  @doc """
  Creates a Pong response to acknowledge a Ping interaction.

  This is used to respond to Discord's ping requests to verify that your
  interaction endpoint is working.

  ## Examples

      iex> DiscordInteractions.InteractionResponse.pong()
      %{type: 1}
  """
  @spec pong() :: t()
  def pong, do: %{type: @pong}

  @doc """
  Creates a response that shows a message in the channel.

  This is the most common response type for application commands and components.

  ## Parameters
  - `data`: Optional message data (content, embeds, etc.)

  ## Examples

      iex> DiscordInteractions.InteractionResponse.channel_message_with_source()
      %{type: 4, data: %{}}

      iex> DiscordInteractions.InteractionResponse.channel_message_with_source(%{content: "Hello!"})
      %{type: 4, data: %{content: "Hello!"}}
  """
  @spec channel_message_with_source(message()) :: t()
  def channel_message_with_source(data \\ %{}),
    do: %{type: @channel_message_with_source, data: data}

  @doc """
  Creates a response that acknowledges an interaction and shows a loading state.

  This allows you to acknowledge the interaction immediately and then follow up
  with a message later using the webhook URL.

  ## Parameters
  - `data`: Optional message data (content, embeds, etc.)

  ## Examples

      iex> DiscordInteractions.InteractionResponse.deferred_channel_message_with_source()
      %{type: 5, data: %{}}
  """
  @spec deferred_channel_message_with_source(message()) :: t()
  def deferred_channel_message_with_source(data \\ %{}),
    do: %{type: @deferred_channel_message_with_source, data: data}

  @doc """
  Creates a response that acknowledges a component interaction with a loading state.

  This is used for component interactions (like buttons) when you need time to process
  before updating the message.

  ## Parameters
  - `data`: Optional message data (content, embeds, etc.)

  ## Examples

      iex> DiscordInteractions.InteractionResponse.deferred_update_message()
      %{type: 6, data: %{}}
  """
  @spec deferred_update_message(message()) :: t()
  def deferred_update_message(data \\ %{}), do: %{type: @deferred_update_message, data: data}

  @doc """
  Creates a response that updates the message a component was attached to.

  This is used for component interactions (like buttons) to update the original message.

  ## Parameters
  - `data`: Optional message data (content, embeds, etc.)

  ## Examples

      iex> DiscordInteractions.InteractionResponse.update_message(%{content: "Updated content"})
      %{type: 7, data: %{content: "Updated content"}}
  """
  @spec update_message(message()) :: t()
  def update_message(data \\ %{}), do: %{type: @update_message, data: data}

  @doc """
  Creates a response with autocomplete suggestions for application command options.

  This is used when a user is typing in an autocomplete-enabled option field.
  Discord will display these choices to the user as they type, allowing them to
  select from the provided options.

  ## Parameters
  - `data`: Can be one of:
    - A list of choice objects (each with `name` and `value` keys)
    - A map with a `choices` key containing a list of choice objects
    - An empty list (default) to show no suggestions

  ## Examples

  Using a list of choices directly:

      iex> choices = [
      ...>   %{name: "Option 1", value: "opt1"},
      ...>   %{name: "Option 2", value: "opt2"}
      ...> ]
      iex> DiscordInteractions.InteractionResponse.application_command_autocomplete_result(choices)
      %{type: 8, data: %{choices: [%{name: "Option 1", value: "opt1"}, %{name: "Option 2", value: "opt2"}]}}

  Using a map with choices:

      iex> choices = [
      ...>   %{name: "Option 1", value: "opt1"},
      ...>   %{name: "Option 2", value: "opt2"}
      ...> ]
      iex> DiscordInteractions.InteractionResponse.application_command_autocomplete_result(%{choices: choices})
      %{type: 8, data: %{choices: [%{name: "Option 1", value: "opt1"}, %{name: "Option 2", value: "opt2"}]}}

  Using the choice helper function:

      iex> choices = [
      ...>   DiscordInteractions.InteractionResponse.choice("Option 1", "opt1"),
      ...>   DiscordInteractions.InteractionResponse.choice("Option 2", "opt2")
      ...> ]
      iex> DiscordInteractions.InteractionResponse.application_command_autocomplete_result(choices)
      %{type: 8, data: %{choices: [%{name: "Option 1", value: "opt1"}, %{name: "Option 2", value: "opt2"}]}}
  """
  @spec application_command_autocomplete_result([choice()] | autocomplete()) :: t()
  def application_command_autocomplete_result(data \\ [])

  def application_command_autocomplete_result(choices) when is_list(choices),
    do: %{type: @application_command_autocomplete_result, data: %{choices: choices}}

  def application_command_autocomplete_result(data),
    do: %{type: @application_command_autocomplete_result, data: data}

  @doc """
  Creates a response that shows a modal dialog.

  This is used to prompt the user for additional input through a form.

  ## Parameters
  - `data`: Modal data (title, custom_id, components)

  ## Examples

      iex> modal_data = %{title: "My Form", custom_id: "my_form", components: []}
      iex> DiscordInteractions.InteractionResponse.modal(modal_data)
      %{type: 9, data: %{title: "My Form", custom_id: "my_form", components: []}}
  """
  @spec modal(modal()) :: t()
  def modal(data \\ %{}), do: %{type: @modal, data: data}

  @doc """
  Creates a response indicating that a premium subscription is required.

  This is used for premium-only features.

  ## Examples

      iex> DiscordInteractions.InteractionResponse.premium_required()
      %{type: 10}
  """
  @spec premium_required() :: t()
  def premium_required, do: %{type: @premium_required}

  @doc """
  Creates a response that launches an activity.

  This is used for launching Discord activities (like games).

  ## Examples

      iex> DiscordInteractions.InteractionResponse.launch_activity()
      %{type: 12}
  """
  @spec launch_activity() :: t()
  def launch_activity, do: %{type: @launch_activity}

  # Message response field setters

  @doc """
  Sets the Text-to-Speech flag on a message response.

  When this flag is set, Discord will read the message aloud in the channel
  using text-to-speech.

  ## Parameters
  - `response`: The interaction response to modify

  ## Examples

      iex> response = DiscordInteractions.InteractionResponse.channel_message_with_source()
      iex> DiscordInteractions.InteractionResponse.tts(response)
      %{type: 4, data: %{tts: true}}
  """
  @spec tts(t()) :: t()
  def tts(%{data: data} = response), do: %{response | data: Map.put(data, :tts, true)}

  @doc """
  Sets the content of a message response.

  This is the main text content of the message.

  ## Parameters
  - `response`: The interaction response to modify
  - `content`: The text content to set

  ## Examples

      iex> response = DiscordInteractions.InteractionResponse.channel_message_with_source()
      iex> DiscordInteractions.InteractionResponse.content(response, "Hello, world!")
      %{type: 4, data: %{content: "Hello, world!"}}
  """
  @spec content(t(), String.t()) :: t()
  def content(%{data: data} = response, content),
    do: %{response | data: Map.put(data, :content, content)}

  @doc """
  Sets the embeds for a message response.

  Embeds are rich content blocks that can contain formatted text, images, and more.
  Use the `DiscordInteractions.Embed` module to create embed objects.

  ## Parameters
  - `response`: The interaction response to modify
  - `embeds`: Array of embed objects

  ## Examples

  Using a simple map for the embed:

      iex> response = DiscordInteractions.InteractionResponse.channel_message_with_source()
      iex> embed = %{title: "My Embed", description: "This is an embed", color: 0x00FF00}
      iex> DiscordInteractions.InteractionResponse.embeds(response, [embed])
      %{type: 4, data: %{embeds: [%{title: "My Embed", description: "This is an embed", color: 0x00FF00}]}}

  Using the Embed module (recommended):

      iex> alias DiscordInteractions.Embed
      iex> response = DiscordInteractions.InteractionResponse.channel_message_with_source()
      iex> embed = Embed.new()
      ...>         |> Embed.title("My Embed")
      ...>         |> Embed.description("This is an embed")
      ...>         |> Embed.color(0x00FF00)
      iex> DiscordInteractions.InteractionResponse.embeds(response, [embed])
      %{type: 4, data: %{embeds: [%{title: "My Embed", description: "This is an embed", color: 0x00FF00}]}}

  Creating a more complex embed:

      iex> alias DiscordInteractions.Embed
      iex> response = DiscordInteractions.InteractionResponse.channel_message_with_source()
      iex> embed = Embed.new()
      ...>         |> Embed.title("User Profile")
      ...>         |> Embed.description("User information")
      ...>         |> Embed.color("#5865F2")
      ...>         |> Embed.thumbnail("https://example.com/avatar.png")
      ...>         |> Embed.add_field("Username", "JohnDoe", true)
      ...>         |> Embed.add_field("Status", "Online", true)
      ...>         |> Embed.footer("Last updated", "https://example.com/icon.png")
      iex> DiscordInteractions.InteractionResponse.embeds(response, [embed])
      %{type: 4, data: %{embeds: [%{title: "User Profile", description: "User information", color: 5793266, thumbnail: %{url: "https://example.com/avatar.png"}, fields: [%{name: "Username", value: "JohnDoe", inline: true}, %{name: "Status", value: "Online", inline: true}], footer: %{text: "Last updated", icon_url: "https://example.com/icon.png"}}]}}
  """
  @spec embeds(t(), [map()]) :: t()
  def embeds(%{data: data} = response, embeds),
    do: %{response | data: Map.put(data, :embeds, embeds)}

  @doc """
  Sets the allowed mentions for a message response.

  This controls which mentions in the message will actually ping users, roles, or everyone.

  ## Parameters
  - `response`: The interaction response to modify
  - `opts`: Options for allowed mentions
    - `:parse`: Types of mentions to parse (`:roles`, `:users`, `:everyone`)
    - `:roles`: Array of role IDs to mention
    - `:users`: Array of user IDs to mention
    - `:replied_user`: Whether to mention the user being replied to

  ## Examples

      iex> response = DiscordInteractions.InteractionResponse.channel_message_with_source()
      iex> DiscordInteractions.InteractionResponse.allowed_mentions(response, parse: [:users])
      %{type: 4, data: %{allowed_mentions: %{parse: [:users], roles: [], users: [], replied_user: false}}}
  """
  @spec allowed_mentions(t(),
          parse: [:roles | :users | :everyone],
          roles: [String.t()],
          users: [String.t()],
          replied_user: boolean()
        ) :: t()
  def allowed_mentions(%{data: data} = response, opts) do
    allowed_mentions = %{
      parse: opts[:parse] || [],
      roles: opts[:roles] || [],
      users: opts[:users] || [],
      replied_user: opts[:replied_user] || false
    }

    %{response | data: Map.put(data, :allowed_mentions, allowed_mentions)}
  end

  @doc """
  Sets the flags for a message response.

  Flags control special behavior of the message, such as making it ephemeral.

  ## Parameters
  - `response`: The interaction response to modify
  - `flags`: Integer value of the flags to set

  ## Examples

      iex> response = DiscordInteractions.InteractionResponse.channel_message_with_source()
      iex> DiscordInteractions.InteractionResponse.flags(response, 64) # Ephemeral flag
      %{type: 4, data: %{flags: 64}}
  """
  @spec flags(t(), integer()) :: t()
  def flags(%{data: data} = response, flags), do: %{response | data: Map.put(data, :flags, flags)}

  @doc """
  Sets the components for a message response.

  Components are interactive elements like buttons and select menus.

  ## Parameters
  - `response`: The interaction response to modify
  - `components`: Array of component objects

  ## Examples

      iex> response = DiscordInteractions.InteractionResponse.channel_message_with_source()
      iex> button = DiscordInteractions.Components.button(style: :primary, label: "Click Me", custom_id: "btn1")
      iex> action_row = DiscordInteractions.Components.action_row(components: [button])
      iex> DiscordInteractions.InteractionResponse.components(response, [action_row])
      %{type: 4, data: %{components: [%{type: 1, components: [%{type: 2, style: 1, label: "Click Me", custom_id: "btn1"}]}]}}
  """
  @spec components(t(), [Components.component()]) :: t()
  def components(%{data: data} = response, components),
    do: %{response | data: Map.put(data, :components, components)}

  @doc """
  Sets the attachments for a message response.

  Attachments are files that are attached to the message.

  ## Parameters
  - `response`: The interaction response to modify
  - `attachments`: Array of attachment objects

  ## Examples

      iex> response = DiscordInteractions.InteractionResponse.channel_message_with_source()
      iex> attachment = %{id: 1, filename: "file.txt", description: "A text file"}
      iex> DiscordInteractions.InteractionResponse.attachments(response, [attachment])
      %{type: 4, data: %{attachments: [%{id: 1, filename: "file.txt", description: "A text file"}]}}
  """
  @spec attachments(t(), [map()]) :: t()
  def attachments(%{data: data} = response, attachments),
    do: %{response | data: Map.put(data, :attachments, attachments)}

  @doc """
  Sets the poll for a message response.

  Polls allow users to vote on options.

  ## Parameters
  - `response`: The interaction response to modify
  - `poll`: Poll object

  ## Examples

      iex> response = DiscordInteractions.InteractionResponse.channel_message_with_source()
      iex> poll = %{question: "Favorite color?", options: [%{text: "Red"}, %{text: "Blue"}]}
      iex> DiscordInteractions.InteractionResponse.poll(response, poll)
      %{type: 4, data: %{poll: %{question: "Favorite color?", options: [%{text: "Red"}, %{text: "Blue"}]}}}
  """
  @spec poll(t(), map()) :: t()
  def poll(%{data: data} = response, poll), do: %{response | data: Map.put(data, :poll, poll)}

  # Message response flags setters

  @doc """
  Sets the suppress embeds flag on a message response.

  When this flag is set, Discord will not display any embeds in the message.

  ## Parameters
  - `response`: The interaction response to modify

  ## Examples

      iex> response = DiscordInteractions.InteractionResponse.channel_message_with_source()
      iex> DiscordInteractions.InteractionResponse.suppress_embeds(response)
      %{type: 4, data: %{flags: 2}}

      iex> response = DiscordInteractions.InteractionResponse.channel_message_with_source(%{flags: 64})
      iex> DiscordInteractions.InteractionResponse.suppress_embeds(response)
      %{type: 4, data: %{flags: 66}}
  """
  @spec suppress_embeds(t()) :: t()
  def suppress_embeds(%{data: %{flags: flags}} = response),
    do: flags(response, @suppress_embeds ||| flags)

  def suppress_embeds(response), do: flags(response, @suppress_embeds)

  @doc """
  Sets the ephemeral flag on a message response.

  When this flag is set, the message will only be visible to the user who
  triggered the interaction and will disappear when the user refreshes or
  navigates away.

  ## Parameters
  - `response`: The interaction response to modify

  ## Examples

      iex> response = DiscordInteractions.InteractionResponse.channel_message_with_source()
      iex> DiscordInteractions.InteractionResponse.ephemeral(response)
      %{type: 4, data: %{flags: 64}}

      iex> response = DiscordInteractions.InteractionResponse.channel_message_with_source(%{flags: 2})
      iex> DiscordInteractions.InteractionResponse.ephemeral(response)
      %{type: 4, data: %{flags: 66}}
  """
  @spec ephemeral(t()) :: t()
  def ephemeral(%{data: %{flags: flags}} = response), do: flags(response, @ephemeral ||| flags)
  def ephemeral(response), do: flags(response, @ephemeral)

  @doc """
  Sets the suppress notifications flag on a message response.

  When this flag is set, the message will not trigger push or desktop notifications.

  ## Parameters
  - `response`: The interaction response to modify

  ## Examples

      iex> response = DiscordInteractions.InteractionResponse.channel_message_with_source()
      iex> DiscordInteractions.InteractionResponse.suppress_notifications(response)
      %{type: 4, data: %{flags: 4096}}

      iex> response = DiscordInteractions.InteractionResponse.channel_message_with_source(%{flags: 64})
      iex> DiscordInteractions.InteractionResponse.suppress_notifications(response)
      %{type: 4, data: %{flags: 4160}}
  """
  @spec suppress_notifications(t()) :: t()
  def suppress_notifications(%{data: %{flags: flags}} = response),
    do: flags(response, @suppress_notifications ||| flags)

  def suppress_notifications(response), do: flags(response, @suppress_notifications)

  @doc """
  Sets the components v2 flag on a message response.

  When this flag is set, it allows you to create fully component-driven messages
  with the new Discord UI components system.

  ## Parameters
  - `response`: The interaction response to modify

  ## Examples

      iex> response = DiscordInteractions.InteractionResponse.channel_message_with_source()
      iex> DiscordInteractions.InteractionResponse.use_components_v2(response)
      %{type: 4, data: %{flags: 32768}}

      iex> response = DiscordInteractions.InteractionResponse.channel_message_with_source(%{flags: 64})
      iex> DiscordInteractions.InteractionResponse.use_components_v2(response)
      %{type: 4, data: %{flags: 32832}}
  """
  @spec use_components_v2(t()) :: t()
  def use_components_v2(%{data: %{flags: flags}} = response),
    do: flags(response, @is_components_v2 ||| flags)

  def use_components_v2(response), do: flags(response, @is_components_v2)

  # Modal field setters

  @doc """
  Sets the title of a modal response.

  The title appears at the top of the modal dialog.

  ## Parameters
  - `response`: The interaction response to modify
  - `title`: The title text to set

  ## Examples

      iex> response = DiscordInteractions.InteractionResponse.modal()
      iex> DiscordInteractions.InteractionResponse.title(response, "My Form")
      %{type: 9, data: %{title: "My Form"}}
  """
  @spec title(t(), String.t()) :: t()
  def title(%{data: data} = response, title), do: %{response | data: Map.put(data, :title, title)}

  @doc """
  Sets the custom ID of a modal response.

  The custom ID is a developer-defined identifier that will be included when
  the modal is submitted, allowing you to identify which modal was used.

  ## Parameters
  - `response`: The interaction response to modify
  - `custom_id`: The custom ID to set

  ## Examples

      iex> response = DiscordInteractions.InteractionResponse.modal()
      iex> DiscordInteractions.InteractionResponse.custom_id(response, "my_form_id")
      %{type: 9, data: %{custom_id: "my_form_id"}}
  """
  @spec custom_id(t(), String.t()) :: t()
  def custom_id(%{data: data} = response, custom_id),
    do: %{response | data: Map.put(data, :custom_id, custom_id)}

  # Autocomplete result field setters

  @doc """
  Creates a choice object for autocomplete suggestions.

  This helper function creates a properly formatted choice object that can be used
  in autocomplete responses.

  ## Parameters
  - `name`: The display name of the choice shown to users
  - `value`: The value of the choice sent to your application when selected

  ## Examples

      iex> DiscordInteractions.InteractionResponse.choice("Red", "red")
      %{name: "Red", value: "red"}

      iex> choices = [
      ...>   DiscordInteractions.InteractionResponse.choice("Red", "red"),
      ...>   DiscordInteractions.InteractionResponse.choice("Blue", "blue")
      ...> ]
      iex> DiscordInteractions.InteractionResponse.application_command_autocomplete_result(choices)
      %{type: 8, data: %{choices: [%{name: "Red", value: "red"}, %{name: "Blue", value: "blue"}]}}
  """
  @spec choice(String.t(), any()) :: choice()
  def choice(name, value), do: %{name: name, value: value}

  @doc """
  Creates a choice object for autocomplete suggestions with localization support.

  This helper function creates a properly formatted choice object that can be used
  in autocomplete responses, including localized names for different languages.

  ## Parameters
  - `name`: The default display name of the choice shown to users
  - `name_localizations`: Map of localized names for different languages (locale code -> name)
  - `value`: The value of the choice sent to your application when selected

  ## Examples

      iex> localizations = %{"es-ES" => "Rojo", "fr" => "Rouge"}
      iex> DiscordInteractions.InteractionResponse.choice("Red", "red", localizations)
      %{name: "Red", value: "red", name_localizations: %{"es-ES" => "Rojo", "fr" => "Rouge"}}
  """
  @spec choice(String.t(), map(), any()) :: choice()
  def choice(name, value, name_localizations),
    do: %{name: name, value: value, name_localizations: name_localizations}
end
