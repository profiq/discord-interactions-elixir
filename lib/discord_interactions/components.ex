defmodule DiscordInteractions.Components do
  @moduledoc """
  Helper module for creating Discord message components.

  This module provides functions for creating various Discord message components
  as defined in the Discord API documentation:
  https://discord.com/developers/docs/components/reference

  ## Component Categories

  ### Layout Components
  - Action Row (type 1): Container for other components
  - Section (type 9): Container for content components
  - Container (type 17): Container for sections

  ### Interactive Components
  - Button (type 2): Clickable button
  - String Select (type 3): Dropdown menu with options
  - Text Input (type 4): Text input field for modals
  - User Select (type 5): Select menu for users
  - Role Select (type 6): Select menu for roles
  - Mentionable Select (type 7): Select menu for mentionable entities
  - Channel Select (type 8): Select menu for channels

  ### Content Components
  - Text Display (type 10): Text content
  - Thumbnail (type 11): Image thumbnail
  - Media Gallery (type 12): Gallery of media
  - File Component (type 13): File attachment
  - Separator (type 14): Visual separator
  """

  @type component :: map()
  @type emoji :: map()
  @type media :: map()

  # Component types
  @action_row 1
  @button 2
  @string_select 3
  @text_input 4
  @user_select 5
  @role_select 6
  @mentionable_select 7
  @channel_select 8
  @section 9
  @text_display 10
  @thumbnail 11
  @media_gallery 12
  @file_component 13
  @separator 14
  @container 17

  # Button styles
  @primary 1
  @secondary 2
  @success 3
  @danger 4
  @link 5
  @premium 6

  # Text input styles
  @short 1
  @paragraph 2

  # Channel types
  @guild_text 0
  @dm 1
  @guild_voice 2
  @group_dm 3
  @guild_category 4
  @guild_announcement 5
  @announcement_thread 10
  @public_thread 11
  @private_thread 12
  @guild_stage_voice 13
  @guild_directory 14
  @guild_forum 15
  @guild_media 16

  defmacrop required(component, key) do
    quote do
      if var!(opts)[unquote(key)], do: Map.put(unquote(component), unquote(key), var!(opts)[unquote(key)]), else: unquote(component)
    end
  end

  defmacrop required(component, key, value) do
    quote do
      if var!(opts)[unquote(key)], do: Map.put(unquote(component), unquote(key), unquote(value)), else: unquote(component)
    end
  end

  defmacrop optional(component, key) do
    quote do
      if var!(opts)[unquote(key)], do: Map.put(unquote(component), unquote(key), var!(opts)[unquote(key)]), else: unquote(component)
    end
  end

  defmacrop optional(component, key, value) do
    quote do
      if var!(opts)[unquote(key)], do: Map.put(unquote(component), unquote(key), unquote(value)), else: unquote(component)
    end
  end

  defmacrop optional_bool(component, key) do
    quote do
      optional(unquote(component), unquote(key), true)
    end
  end

  @doc """
  Creates an action row component.

  Action rows are containers for other interactive components and are required
  for buttons and select menus to be displayed in messages.

  ## Options
  - `components` - List of components to include in the action row
  - `id` - Optional identifier for the action row

  ## Examples

      # Create an action row with a button
      DiscordInteractions.Components.action_row(
        components: [
          DiscordInteractions.Components.button(
            style: :primary,
            label: "Click Me",
            custom_id: "click_button"
          )
        ]
      )
  """
  @spec action_row([id: integer(), components: [component()]]) :: component()
  def action_row(opts) do
    %{type: @action_row}
    |> optional(:id)
    |> required(:components)
  end

  @doc """
  Creates a button component.

  ## Options
  - `style` - Button style (`:primary`, `:secondary`, `:success`, `:danger`, `:link`, `:premium`)
  - `label` - Button label text
  - `custom_id` - Custom identifier for the button (required for non-link buttons)
  - `url` - URL for link buttons (required for link buttons)
  - `emoji` - Emoji to display on the button (optional)
  - `disabled` - Whether the button is disabled (default: `false`)

  ## Examples

      # Create a primary button
      DiscordInteractions.Components.button(
        style: :primary,
        label: "Click Me",
        custom_id: "click_button"
      )

      # Create a link button
      DiscordInteractions.Components.button(
        style: :link,
        label: "Visit Website",
        url: "https://example.com"
      )

      # Create a button with an emoji
      DiscordInteractions.Components.button(
        style: :success,
        label: "Confirm",
        custom_id: "confirm_button",
        emoji: %{name: "✅"}
      )
  """
  @spec button(id: integer(), style: atom(), label: String.t(), custom_id: String.t(), url: String.t(), emoji: emoji(), disabled: boolean()) :: component()
  def button(opts) do
    %{type: @button}
    |> optional(:id)
    |> required(:style, button_style(opts[:style]))
    |> optional(:label)
    |> optional(:emoji)
    |> optional_bool(:disabled)
    |> case do
      %{style: @link} = button ->
        required(button, :url)

      %{style: @premium} = button ->
        required(button, :sku_id)

      button ->
        required(button, :custom_id)
    end
  end

  # Helper function to convert button style atoms to integers
  defp button_style(style) do
    case style do
      :primary -> @primary
      :secondary -> @secondary
      :success -> @success
      :danger -> @danger
      :link -> @link
      :premium -> @premium
      _ -> @primary
    end
  end

  @doc """
  Creates a string select menu component.

  ## Options
  - `custom_id` - Custom identifier for the select menu
  - `options` - List of options for the select menu
  - `placeholder` - Placeholder text when no option is selected (optional)
  - `min_values` - Minimum number of selected values (default: 1)
  - `max_values` - Maximum number of selected values (default: 1)
  - `disabled` - Whether the select menu is disabled (default: `false`)

  ## Examples

      # Create a select menu with options
      DiscordInteractions.Components.string_select(
        custom_id: "select_option",
        options: [
          %{label: "Option 1", value: "opt1"},
          %{label: "Option 2", value: "opt2"}
        ],
        placeholder: "Select an option"
      )
  """
  @spec string_select([id: integer(), custom_id: String.t(), options: [map()], placeholder: String.t(), min_values: non_neg_integer(), max_values: non_neg_integer(), disabled: boolean()]) :: component()
  def string_select(opts) do
    %{type: @string_select}
    |> optional(:id)
    |> required(:custom_id)
    |> required(:options)
    |> optional(:placeholder)
    |> required(:min_values)
    |> required(:max_values)
    |> optional_bool(:disabled)
  end

  @spec select_option([label: String.t(), value: String.t(), description: String.t(), emoji: emoji(), default: boolean()]) :: map()
  def select_option(opts) do
    %{}
    |> required(:label)
    |> required(:value)
    |> optional(:description)
    |> optional(:emoji)
    |> optional_bool(:default)
  end

  @doc """
  Creates a text input component for modals.

  ## Options
  - `custom_id` - Custom identifier for the text input
  - `style` - Text input style (`:short` or `:paragraph`)
  - `label` - Label for the text input
  - `min_length` - Minimum input length (optional)
  - `max_length` - Maximum input length (optional)
  - `required` - Whether the input is required (default: `true`)
  - `value` - Pre-filled value (optional)
  - `placeholder` - Placeholder text (optional)

  ## Examples

      # Create a short text input
      DiscordInteractions.Components.text_input(
        custom_id: "name_input",
        style: :short,
        label: "Name",
        placeholder: "Enter your name"
      )

      # Create a paragraph text input
      DiscordInteractions.Components.text_input(
        custom_id: "feedback_input",
        style: :paragraph,
        label: "Feedback",
        min_length: 10,
        max_length: 1000,
        placeholder: "Enter your feedback"
      )
  """
  @spec text_input([id: integer(), custom_id: String.t(), style: atom(), label: String.t(), min_length: non_neg_integer(), max_length: non_neg_integer(), required: boolean(), value: String.t(), placeholder: String.t()]) :: component()
  def text_input(opts) do
    style = case opts[:style] do
      :short -> @short
      :paragraph -> @paragraph
    end

    %{type: @text_input}
    |> optional(:id)
    |> required(:custom_id)
    |> required(:style, style)
    |> required(:label)
    |> optional(:min_length)
    |> optional(:max_length)
    |> optional_bool(:required)
    |> optional(:value)
    |> optional(:placeholder)
  end

  @doc """
  Creates a user select menu component.

  ## Options
  - `custom_id` - Custom identifier for the select menu
  - `placeholder` - Placeholder text when no option is selected (optional)
  - `min_values` - Minimum number of selected values (default: 1)
  - `max_values` - Maximum number of selected values (default: 1)
  - `disabled` - Whether the select menu is disabled (default: `false`)

  ## Examples

      # Create a user select menu
      DiscordInteractions.Components.user_select(
        custom_id: "select_user",
        placeholder: "Select a user"
      )
  """
  @spec user_select([id: integer(), custom_id: String.t(), placeholder: String.t(), min_values: non_neg_integer(), max_values: non_neg_integer(), disabled: boolean()]) :: component()
  def user_select(opts) do
    %{type: @user_select}
    |> optional(:id)
    |> required(:custom_id)
    |> optional(:placeholder)
    |> optional(:default_values)
    |> required(:min_values)
    |> required(:max_values)
    |> optional_bool(:disabled)
  end

  @doc """
  Creates a role select menu component.

  ## Options
  - `custom_id` - Custom identifier for the select menu
  - `placeholder` - Placeholder text when no option is selected (optional)
  - `min_values` - Minimum number of selected values (default: 1)
  - `max_values` - Maximum number of selected values (default: 1)
  - `disabled` - Whether the select menu is disabled (default: `false`)

  ## Examples

      # Create a role select menu
      DiscordInteractions.Components.role_select(
        custom_id: "select_role",
        placeholder: "Select a role"
      )
  """
  @spec role_select([id: integer(), custom_id: String.t(), placeholder: String.t(), min_values: non_neg_integer(), max_values: non_neg_integer(), disabled: boolean()]) :: component()
  def role_select(opts) do
    %{type: @role_select}
    |> optional(:id)
    |> required(:custom_id)
    |> optional(:placeholder)
    |> optional(:default_values)
    |> optional(:min_values)
    |> optional(:max_values)
    |> optional_bool(:disabled)
  end

  @doc """
  Creates a mentionable select menu component.

  ## Options
  - `custom_id` - Custom identifier for the select menu
  - `placeholder` - Placeholder text when no option is selected (optional)
  - `min_values` - Minimum number of selected values (default: 1)
  - `max_values` - Maximum number of selected values (default: 1)
  - `disabled` - Whether the select menu is disabled (default: `false`)

  ## Examples

      # Create a mentionable select menu
      DiscordInteractions.Components.mentionable_select(
        custom_id: "select_mentionable",
        placeholder: "Select a user or role"
      )
  """
  @spec mentionable_select([id: integer(), custom_id: String.t(), placeholder: String.t(), min_values: non_neg_integer(), max_values: non_neg_integer(), disabled: boolean()]) :: component()
  def mentionable_select(opts) do
    %{type: @mentionable_select}
    |> optional(:id)
    |> required(:custom_id)
    |> optional(:placeholder)
    |> optional(:default_values)
    |> required(:min_values)
    |> required(:max_values)
    |> optional_bool(:disabled)
  end

  @doc """
  Creates a channel select menu component.

  ## Options
  - `custom_id` - Custom identifier for the select menu
  - `placeholder` - Placeholder text when no option is selected (optional)
  - `min_values` - Minimum number of selected values (default: 1)
  - `max_values` - Maximum number of selected values (default: 1)
  - `channel_types` - List of channel types to include (optional)
  - `disabled` - Whether the select menu is disabled (default: `false`)

  ## Examples

      # Create a channel select menu
      DiscordInteractions.Components.channel_select(
        custom_id: "select_channel",
        placeholder: "Select a channel",
        channel_types: [:guild_text, :guild_voice] # Text and voice channels
      )
  """
  @spec channel_select([id: integer(), custom_id: String.t(), channel_types: [atom()], placeholder: String.t(), min_values: non_neg_integer(), max_values: non_neg_integer(), disabled: boolean()]) :: component()
  def channel_select(opts) do
    %{type: @channel_select}
    |> optional(:id)
    |> required(:custom_id)
    |> optional(:channel_types, Enum.map(opts[:channel_types], &channel_type/1))
    |> optional(:placeholder)
    |> optional(:default_values)
    |> required(:min_values)
    |> required(:max_values)
    |> optional_bool(:disabled)
  end

  defp channel_type(type) do
    case type do
      :guild_text -> @guild_text
      :dm -> @dm
      :guild_voice -> @guild_voice
      :group_dm -> @group_dm
      :guild_category -> @guild_category
      :guild_announcement -> @guild_announcement
      :announcement_thread -> @announcement_thread
      :public_thread -> @public_thread
      :private_thread -> @private_thread
      :guild_stage_voice -> @guild_stage_voice
      :guild_directory -> @guild_directory
      :guild_forum -> @guild_forum
      :guild_media -> @guild_media
      _ -> @guild_text
    end
  end

  @doc """
  Creates a section component.

  Sections are containers for content components like text, thumbnails, etc.

  ## Options
  - `components` - List of content components to include in the section
  - `accessory` - Accessory component (e.g., thumbnail) to display alongside the section
  - `id` - Optional identifier for the section

  ## Examples

      # Create a section with text display and thumbnail
      DiscordInteractions.Components.section(
        components: [
          DiscordInteractions.Components.text_display(
            content: "This is some text content"
          )
        ],
        accessory: DiscordInteractions.Components.thumbnail(
          DiscordInteractions.Components.unfurled_media_item("https://example.com/image.png")
        )
      )
  """
  @spec section([id: integer(), components: [component()], accessory: component()]) :: component()
  def section(opts) do
    %{type: @section}
    |> optional(:id)
    |> required(:components)
    |> required(:accessory)
  end

  @doc """
  Creates a text display component.

  ## Options
  - `content` - Text content to display
  - `style` - Text style (`:normal`, `:heading`, `:subheading`, `:quote`, `:code_block`)
  - `format` - Text formatting (optional)

  ## Examples

      # Create a normal text display
      DiscordInteractions.Components.text_display(
        content: "This is some text content"
      )

      # Create a heading text display
      DiscordInteractions.Components.text_display(
        content: "This is a heading",
        style: :heading
      )
  """
  @spec text_display([id: integer(), content: String.t()]) :: component()
  def text_display(opts) do
    %{type: @text_display}
    |> optional(:id)
    |> required(:content)
  end

  @doc """
  Creates a thumbnail component.

  ## Options
  - `media` - Media object with URL of the thumbnail image
  - `id` - Optional identifier for the thumbnail
  - `description` - Optional description for the thumbnail
  - `spoiler` - Whether the thumbnail should be marked as a spoiler (default: `false`)

  ## Examples

      # Create a thumbnail
      DiscordInteractions.Components.thumbnail(
        media: DiscordInteractions.Components.unfurled_media_item("https://example.com/image.png"),
        description: "Example image"
      )
  """
  @spec thumbnail([id: integer(), media: String.t() | media(), description: String.t(), spoiler: boolean()]) :: component()
  def thumbnail(opts) do
    %{type: @thumbnail}
    |> optional(:id)
    |> required(:media, unfurled_media_item(opts[:media]))
    |> optional(:description)
    |> optional_bool(:spoiler)
  end

  @doc """
  Creates a media gallery component.

  ## Options
  - `items` - List of media items to include in the gallery
  - `id` - Optional identifier for the media gallery

  ## Examples

      # Create a media gallery
      DiscordInteractions.Components.media_gallery(
        items: [
          DiscordInteractions.Components.unfurled_media_item("https://example.com/image1.png"),
          DiscordInteractions.Components.unfurled_media_item("https://example.com/image2.png")
        ]
      )
  """
  @spec media_gallery([id: integer(), items: [String.t() | media()]]) :: component()
  def media_gallery(opts) do
    %{type: @media_gallery}
    |> optional(:id)
    |> required(:items, Enum.map(opts[:items], &unfurled_media_item/1))
  end

  @doc """
  Creates a file component.

  ## Options
  - `file` - File object with URL and filename
  - `id` - Optional identifier for the file component
  - `spoiler` - Whether the file should be marked as a spoiler (default: `false`)

  ## Examples

      # Create a file component
      DiscordInteractions.Components.file(
        file: DiscordInteractions.Components.unfurled_media_item("https://example.com/document.pdf")
      )
  """
  @spec file([id: integer(), file: String.t() | media(), spoiler: boolean()]) :: component()
  def file(opts) do
    %{type: @file_component}
    |> optional(:id)
    |> required(:file, unfurled_media_item(opts[:file]))
    |> optional_bool(:spoiler)
  end

  @doc """
  Creates a separator component.

  ## Options
  - `id` - Optional identifier for the separator
  - `divider` - Whether to show a divider line (default: `false`)
  - `spacing` - Spacing size ("small", "medium", "large")

  ## Examples

      # Create a separator with a divider
      DiscordInteractions.Components.separator(divider: true)

      # Create a separator with medium spacing
      DiscordInteractions.Components.separator(spacing: "medium")
  """
  @spec separator([id: integer(), divider: boolean(), spacing: String.t()]) :: component()
  def separator(opts) do
    %{type: @separator}
    |> optional(:id)
    |> optional_bool(:divider)
    |> optional(:spacing)
  end

  @doc """
  Creates a container component.

  Containers are used to group sections together.

  ## Options
  - `components` - List of section components to include in the container
  - `id` - Optional identifier for the container
  - `accent_color` - Optional accent color for the container (integer color value)
  - `spoiler` - Whether the container should be marked as a spoiler (default: `false`)

  ## Examples

      # Create a container with a section
      DiscordInteractions.Components.container(
        components: [
          DiscordInteractions.Components.section(
            components: [
              DiscordInteractions.Components.text_display(
                content: "This is some text content"
              )
            ],
            accessory: DiscordInteractions.Components.thumbnail(
              media: DiscordInteractions.Components.unfurled_media_item("https://example.com/image.png")
            )
          )
        ],
        accent_color: 0xFF0000
      )
  """
  @spec container([id: integer(), components: [component()], accent_color: integer() | String.t(), spoiler: boolean()]) :: component()
  def container(opts) do
    %{type: @container}
    |> optional(:id)
    |> required(:components)
    |> optional(:accent_color)
    |> optional_bool(:spoiler)
  end

  @spec unfurled_media_item(String.t() | map()) :: media()
  defp unfurled_media_item(%{} = item), do: item

  defp unfurled_media_item(url) do
    %{url: url}
  end

end
