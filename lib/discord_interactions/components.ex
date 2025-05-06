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
  @type components :: list(component())

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

  # Text input styles
  @short 1
  @paragraph 2

  # Text display styles
  @normal 0
  @heading 1
  @subheading 2
  @quote 3
  @code_block 4

  @doc """
  Creates an action row component.

  Action rows are containers for other interactive components and are required
  for buttons and select menus to be displayed in messages.

  ## Options
  - `components` - List of components to include in the action row

  ## Examples

      # Create an action row with a button
      DiscordInteractions.Components.action_row([
        DiscordInteractions.Components.button(
          style: :primary,
          label: "Click Me",
          custom_id: "click_button"
        )
      ])
  """
  @spec action_row(components()) :: component()
  def action_row(components) when is_list(components) do
    %{
      "type" => @action_row,
      "components" => components
    }
  end

  @doc """
  Creates a section component.

  Sections are containers for content components like text, thumbnails, etc.

  ## Options
  - `components` - List of content components to include in the section

  ## Examples

      # Create a section with text display
      DiscordInteractions.Components.section([
        DiscordInteractions.Components.text_display(
          content: "This is some text content"
        )
      ])
  """
  @spec section(components()) :: component()
  def section(components) when is_list(components) do
    %{
      "type" => @section,
      "components" => components
    }
  end

  @doc """
  Creates a container component.

  Containers are used to group sections together.

  ## Options
  - `components` - List of section components to include in the container

  ## Examples

      # Create a container with a section
      DiscordInteractions.Components.container([
        DiscordInteractions.Components.section([
          DiscordInteractions.Components.text_display(
            content: "This is some text content"
          )
        ])
      ])
  """
  @spec container(components()) :: component()
  def container(components) when is_list(components) do
    %{
      "type" => @container,
      "components" => components
    }
  end

  @doc """
  Creates a button component.

  ## Options
  - `style` - Button style (`:primary`, `:secondary`, `:success`, `:danger`, `:link`)
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
  @spec button(keyword()) :: component()
  def button(opts) do
    style = get_button_style(opts[:style])

    button = %{
      "type" => @button,
      "style" => style,
      "label" => opts[:label]
    }

    button = if style == @link do
      Map.put(button, "url", opts[:url])
    else
      Map.put(button, "custom_id", opts[:custom_id])
    end

    button = if opts[:emoji], do: Map.put(button, "emoji", opts[:emoji]), else: button
    button = if opts[:disabled], do: Map.put(button, "disabled", true), else: button

    button
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
  @spec string_select(keyword()) :: component()
  def string_select(opts) do
    select = %{
      "type" => @string_select,
      "custom_id" => opts[:custom_id],
      "options" => opts[:options]
    }

    select = if opts[:placeholder], do: Map.put(select, "placeholder", opts[:placeholder]), else: select
    select = if opts[:min_values], do: Map.put(select, "min_values", opts[:min_values]), else: select
    select = if opts[:max_values], do: Map.put(select, "max_values", opts[:max_values]), else: select
    select = if opts[:disabled], do: Map.put(select, "disabled", true), else: select

    select
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
  @spec user_select(keyword()) :: component()
  def user_select(opts) do
    select = %{
      "type" => @user_select,
      "custom_id" => opts[:custom_id]
    }

    select = if opts[:placeholder], do: Map.put(select, "placeholder", opts[:placeholder]), else: select
    select = if opts[:min_values], do: Map.put(select, "min_values", opts[:min_values]), else: select
    select = if opts[:max_values], do: Map.put(select, "max_values", opts[:max_values]), else: select
    select = if opts[:disabled], do: Map.put(select, "disabled", true), else: select

    select
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
  @spec role_select(keyword()) :: component()
  def role_select(opts) do
    select = %{
      "type" => @role_select,
      "custom_id" => opts[:custom_id]
    }

    select = if opts[:placeholder], do: Map.put(select, "placeholder", opts[:placeholder]), else: select
    select = if opts[:min_values], do: Map.put(select, "min_values", opts[:min_values]), else: select
    select = if opts[:max_values], do: Map.put(select, "max_values", opts[:max_values]), else: select
    select = if opts[:disabled], do: Map.put(select, "disabled", true), else: select

    select
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
  @spec mentionable_select(keyword()) :: component()
  def mentionable_select(opts) do
    select = %{
      "type" => @mentionable_select,
      "custom_id" => opts[:custom_id]
    }

    select = if opts[:placeholder], do: Map.put(select, "placeholder", opts[:placeholder]), else: select
    select = if opts[:min_values], do: Map.put(select, "min_values", opts[:min_values]), else: select
    select = if opts[:max_values], do: Map.put(select, "max_values", opts[:max_values]), else: select
    select = if opts[:disabled], do: Map.put(select, "disabled", true), else: select

    select
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
        channel_types: [0, 2] # Text and voice channels
      )
  """
  @spec channel_select(keyword()) :: component()
  def channel_select(opts) do
    select = %{
      "type" => @channel_select,
      "custom_id" => opts[:custom_id]
    }

    select = if opts[:placeholder], do: Map.put(select, "placeholder", opts[:placeholder]), else: select
    select = if opts[:min_values], do: Map.put(select, "min_values", opts[:min_values]), else: select
    select = if opts[:max_values], do: Map.put(select, "max_values", opts[:max_values]), else: select
    select = if opts[:channel_types], do: Map.put(select, "channel_types", opts[:channel_types]), else: select
    select = if opts[:disabled], do: Map.put(select, "disabled", true), else: select

    select
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
  @spec text_input(keyword()) :: component()
  def text_input(opts) do
    style = case opts[:style] do
      :short -> @short
      :paragraph -> @paragraph
      _ -> @short
    end

    input = %{
      "type" => @text_input,
      "custom_id" => opts[:custom_id],
      "style" => style,
      "label" => opts[:label]
    }

    input = if opts[:min_length], do: Map.put(input, "min_length", opts[:min_length]), else: input
    input = if opts[:max_length], do: Map.put(input, "max_length", opts[:max_length]), else: input
    input = if is_nil(opts[:required]), do: Map.put(input, "required", true), else: Map.put(input, "required", opts[:required])
    input = if opts[:value], do: Map.put(input, "value", opts[:value]), else: input
    input = if opts[:placeholder], do: Map.put(input, "placeholder", opts[:placeholder]), else: input

    input
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
  @spec text_display(keyword()) :: component()
  def text_display(opts) do
    style = case opts[:style] do
      :normal -> @normal
      :heading -> @heading
      :subheading -> @subheading
      :quote -> @quote
      :code_block -> @code_block
      _ -> @normal
    end

    text = %{
      "type" => @text_display,
      "content" => opts[:content],
      "style" => style
    }

    text = if opts[:format], do: Map.put(text, "format", opts[:format]), else: text

    text
  end

  @doc """
  Creates a thumbnail component.

  ## Options
  - `url` - URL of the thumbnail image
  - `width` - Width of the thumbnail (optional)
  - `height` - Height of the thumbnail (optional)

  ## Examples

      # Create a thumbnail
      DiscordInteractions.Components.thumbnail(
        url: "https://example.com/image.png"
      )
  """
  @spec thumbnail(keyword()) :: component()
  def thumbnail(opts) do
    thumbnail = %{
      "type" => @thumbnail,
      "url" => opts[:url]
    }

    thumbnail = if opts[:width], do: Map.put(thumbnail, "width", opts[:width]), else: thumbnail
    thumbnail = if opts[:height], do: Map.put(thumbnail, "height", opts[:height]), else: thumbnail

    thumbnail
  end

  @doc """
  Creates a media gallery component.

  ## Options
  - `media` - List of media items to include in the gallery

  ## Examples

      # Create a media gallery
      DiscordInteractions.Components.media_gallery([
        %{url: "https://example.com/image1.png"},
        %{url: "https://example.com/image2.png"}
      ])
  """
  @spec media_gallery(list(map())) :: component()
  def media_gallery(media) when is_list(media) do
    %{
      "type" => @media_gallery,
      "media" => media
    }
  end

  @doc """
  Creates a file component.

  ## Options
  - `url` - URL of the file
  - `filename` - Name of the file

  ## Examples

      # Create a file component
      DiscordInteractions.Components.file(
        url: "https://example.com/document.pdf",
        filename: "document.pdf"
      )
  """
  @spec file(keyword()) :: component()
  def file(opts) do
    %{
      "type" => @file_component,
      "url" => opts[:url],
      "filename" => opts[:filename]
    }
  end

  @doc """
  Creates a separator component.

  ## Examples

      # Create a separator
      DiscordInteractions.Components.separator()
  """
  @spec separator() :: component()
  def separator() do
    %{
      "type" => @separator
    }
  end

  @doc """
  Creates a modal response.

  ## Options
  - `custom_id` - Custom identifier for the modal
  - `title` - Title of the modal
  - `components` - List of action rows containing components for the modal

  ## Examples

      # Create a modal with a text input
      DiscordInteractions.Components.modal(
        custom_id: "feedback_modal",
        title: "Submit Feedback",
        components: [
          DiscordInteractions.Components.action_row([
            DiscordInteractions.Components.text_input(
              custom_id: "feedback_input",
              style: :paragraph,
              label: "Feedback",
              placeholder: "Enter your feedback"
            )
          ])
        ]
      )
  """
  @spec modal(keyword()) :: map()
  def modal(opts) do
    %{
      "type" => 9, # Modal response type
      "data" => %{
        "custom_id" => opts[:custom_id],
        "title" => opts[:title],
        "components" => opts[:components]
      }
    }
  end

  @doc """
  Creates a message response with components.

  ## Options
  - `content` - Message content (optional)
  - `embeds` - List of embeds (optional)
  - `components` - List of components (optional)
  - `ephemeral` - Whether the message is ephemeral (default: `false`)

  ## Examples

      # Create a message with content and a button
      DiscordInteractions.Components.message(
        content: "Click the button below:",
        components: [
          DiscordInteractions.Components.action_row([
            DiscordInteractions.Components.button(
              style: :primary,
              label: "Click Me",
              custom_id: "click_button"
            )
          ])
        ],
        ephemeral: true
      )
  """
  @spec message(keyword()) :: map()
  def message(opts) do
    message = %{
      "type" => 4, # Message response type
      "data" => %{}
    }

    data = message["data"]
    data = if opts[:content], do: Map.put(data, "content", opts[:content]), else: data
    data = if opts[:embeds], do: Map.put(data, "embeds", opts[:embeds]), else: data
    data = if opts[:components], do: Map.put(data, "components", opts[:components]), else: data
    data = if opts[:ephemeral], do: Map.put(data, "flags", 64), else: data

    %{message | "data" => data}
  end

  # Helper function to convert button style atoms to integers
  defp get_button_style(style) do
    case style do
      :primary -> @primary
      :secondary -> @secondary
      :success -> @success
      :danger -> @danger
      :link -> @link
      _ -> @primary
    end
  end
end
