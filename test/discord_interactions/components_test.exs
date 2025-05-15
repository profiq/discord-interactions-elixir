defmodule DiscordInteractions.ComponentsTest do
  use ExUnit.Case
  doctest DiscordInteractions.Components

  alias DiscordInteractions.Components

  describe "action_row/1" do
    test "creates an action row with components" do
      components = [%{type: 2, label: "Button", custom_id: "btn1"}]
      assert %{type: 1, components: ^components} = Components.action_row(components: components)
    end

    test "creates an action row with id" do
      components = [%{type: 2, label: "Button", custom_id: "btn1"}]

      assert %{type: 1, id: 123, components: ^components} =
               Components.action_row(id: 123, components: components)
    end
  end

  describe "button/1" do
    test "creates a primary button" do
      assert %{
               type: 2,
               style: 1,
               label: "Click Me",
               custom_id: "click_button"
             } =
               Components.button(
                 style: :primary,
                 label: "Click Me",
                 custom_id: "click_button"
               )
    end

    test "creates a secondary button" do
      assert %{
               type: 2,
               style: 2,
               label: "Click Me",
               custom_id: "click_button"
             } =
               Components.button(
                 style: :secondary,
                 label: "Click Me",
                 custom_id: "click_button"
               )
    end

    test "creates a success button" do
      assert %{
               type: 2,
               style: 3,
               label: "Click Me",
               custom_id: "click_button"
             } =
               Components.button(
                 style: :success,
                 label: "Click Me",
                 custom_id: "click_button"
               )
    end

    test "creates a danger button" do
      assert %{
               type: 2,
               style: 4,
               label: "Click Me",
               custom_id: "click_button"
             } =
               Components.button(
                 style: :danger,
                 label: "Click Me",
                 custom_id: "click_button"
               )
    end

    test "creates a link button" do
      assert %{
               type: 2,
               style: 5,
               label: "Visit Website",
               url: "https://example.com"
             } =
               Components.button(
                 style: :link,
                 label: "Visit Website",
                 url: "https://example.com"
               )
    end

    test "creates a premium button" do
      assert %{
               type: 2,
               style: 6,
               label: "Premium Feature",
               sku_id: "123456789"
             } =
               Components.button(
                 style: :premium,
                 label: "Premium Feature",
                 sku_id: "123456789"
               )
    end

    test "creates a button with emoji" do
      emoji = %{name: "✅"}

      assert %{
               type: 2,
               style: 1,
               label: "Confirm",
               custom_id: "confirm_button",
               emoji: ^emoji
             } =
               Components.button(
                 style: :primary,
                 label: "Confirm",
                 custom_id: "confirm_button",
                 emoji: emoji
               )
    end

    test "creates a disabled button" do
      assert %{
               type: 2,
               style: 1,
               label: "Click Me",
               custom_id: "click_button",
               disabled: true
             } =
               Components.button(
                 style: :primary,
                 label: "Click Me",
                 custom_id: "click_button",
                 disabled: true
               )
    end
  end

  describe "emoji/1" do
    test "creates a simple emoji" do
      assert %{name: "✅"} = Components.emoji(name: "✅")
    end

    test "creates a custom emoji with id" do
      assert %{
               name: "custom_emoji",
               id: "123456789"
             } =
               Components.emoji(
                 name: "custom_emoji",
                 id: "123456789"
               )
    end

    test "creates an animated emoji" do
      assert %{
               name: "custom_emoji",
               id: "123456789",
               animated: true
             } =
               Components.emoji(
                 name: "custom_emoji",
                 id: "123456789",
                 animated: true
               )
    end
  end

  describe "string_select/1" do
    test "creates a string select menu with options" do
      options = [
        %{label: "Option 1", value: "opt1"},
        %{label: "Option 2", value: "opt2"}
      ]

      assert %{
               type: 3,
               custom_id: "select_option",
               options: ^options,
               min_values: 1,
               max_values: 1
             } =
               Components.string_select(
                 custom_id: "select_option",
                 options: options,
                 min_values: 1,
                 max_values: 1
               )
    end

    test "creates a string select menu with placeholder" do
      options = [%{label: "Option 1", value: "opt1"}]

      assert %{
               type: 3,
               custom_id: "select_option",
               options: ^options,
               placeholder: "Select an option",
               min_values: 1,
               max_values: 1
             } =
               Components.string_select(
                 custom_id: "select_option",
                 options: options,
                 placeholder: "Select an option",
                 min_values: 1,
                 max_values: 1
               )
    end

    test "creates a disabled string select menu" do
      options = [%{label: "Option 1", value: "opt1"}]

      assert %{
               type: 3,
               custom_id: "select_option",
               options: ^options,
               min_values: 1,
               max_values: 1,
               disabled: true
             } =
               Components.string_select(
                 custom_id: "select_option",
                 options: options,
                 min_values: 1,
                 max_values: 1,
                 disabled: true
               )
    end
  end

  describe "select_option/1" do
    test "creates a basic select option" do
      assert %{
               label: "Option 1",
               value: "opt1"
             } =
               Components.select_option(
                 label: "Option 1",
                 value: "opt1"
               )
    end

    test "creates a select option with description" do
      assert %{
               label: "Option 1",
               value: "opt1",
               description: "This is option 1"
             } =
               Components.select_option(
                 label: "Option 1",
                 value: "opt1",
                 description: "This is option 1"
               )
    end
  end

  describe "text_input/1" do
    test "creates a short text input" do
      assert %{
               type: 4,
               custom_id: "name_input",
               style: 1,
               label: "Name",
               placeholder: "Enter your name"
             } =
               Components.text_input(
                 custom_id: "name_input",
                 style: :short,
                 label: "Name",
                 placeholder: "Enter your name"
               )
    end

    test "creates a paragraph text input" do
      assert %{
               type: 4,
               custom_id: "feedback_input",
               style: 2,
               label: "Feedback",
               min_length: 10,
               max_length: 1000,
               placeholder: "Enter your feedback"
             } =
               Components.text_input(
                 custom_id: "feedback_input",
                 style: :paragraph,
                 label: "Feedback",
                 min_length: 10,
                 max_length: 1000,
                 placeholder: "Enter your feedback"
               )
    end

    test "creates a required text input" do
      assert %{
               type: 4,
               custom_id: "name_input",
               style: 1,
               label: "Name",
               required: true
             } =
               Components.text_input(
                 custom_id: "name_input",
                 style: :short,
                 label: "Name",
                 required: true
               )
    end

    test "creates a text input with pre-filled value" do
      assert %{
               type: 4,
               custom_id: "name_input",
               style: 1,
               label: "Name",
               value: "John Doe"
             } =
               Components.text_input(
                 custom_id: "name_input",
                 style: :short,
                 label: "Name",
                 value: "John Doe"
               )
    end
  end

  describe "user_select/1" do
    test "creates a user select menu" do
      assert %{
               type: 5,
               custom_id: "select_user",
               placeholder: "Select a user",
               min_values: 1,
               max_values: 1
             } =
               Components.user_select(
                 custom_id: "select_user",
                 placeholder: "Select a user",
                 min_values: 1,
                 max_values: 1
               )
    end

    test "creates a user select menu with default values" do
      default_values = [%{id: "123456789", type: "user"}]

      assert %{
               type: 5,
               custom_id: "select_user",
               placeholder: "Select a user",
               default_values: ^default_values,
               min_values: 1,
               max_values: 3
             } =
               Components.user_select(
                 custom_id: "select_user",
                 placeholder: "Select a user",
                 default_values: default_values,
                 min_values: 1,
                 max_values: 3
               )
    end

    test "creates a disabled user select menu" do
      assert %{
               type: 5,
               custom_id: "select_user",
               min_values: 1,
               max_values: 1,
               disabled: true
             } =
               Components.user_select(
                 custom_id: "select_user",
                 min_values: 1,
                 max_values: 1,
                 disabled: true
               )
    end
  end

  describe "role_select/1" do
    test "creates a role select menu" do
      assert %{
               type: 6,
               custom_id: "select_role",
               placeholder: "Select a role"
             } =
               Components.role_select(
                 custom_id: "select_role",
                 placeholder: "Select a role"
               )
    end

    test "creates a role select menu with default values" do
      default_values = [%{id: "123456789", type: "role"}]

      assert %{
               type: 6,
               custom_id: "select_role",
               default_values: ^default_values
             } =
               Components.role_select(
                 custom_id: "select_role",
                 default_values: default_values
               )
    end

    test "creates a disabled role select menu" do
      assert %{
               type: 6,
               custom_id: "select_role",
               disabled: true
             } =
               Components.role_select(
                 custom_id: "select_role",
                 disabled: true
               )
    end
  end

  describe "mentionable_select/1" do
    test "creates a mentionable select menu" do
      assert %{
               type: 7,
               custom_id: "select_mentionable",
               placeholder: "Select a user or role",
               min_values: 1,
               max_values: 1
             } =
               Components.mentionable_select(
                 custom_id: "select_mentionable",
                 placeholder: "Select a user or role",
                 min_values: 1,
                 max_values: 1
               )
    end

    test "creates a mentionable select menu with default values" do
      default_values = [
        %{id: "123456789", type: "user"},
        %{id: "987654321", type: "role"}
      ]

      assert %{
               type: 7,
               custom_id: "select_mentionable",
               default_values: ^default_values,
               min_values: 1,
               max_values: 5
             } =
               Components.mentionable_select(
                 custom_id: "select_mentionable",
                 default_values: default_values,
                 min_values: 1,
                 max_values: 5
               )
    end
  end

  describe "channel_select/1" do
    test "creates a channel select menu" do
      assert %{
               type: 8,
               custom_id: "select_channel",
               placeholder: "Select a channel",
               min_values: 1,
               max_values: 1
             } =
               Components.channel_select(
                 custom_id: "select_channel",
                 placeholder: "Select a channel",
                 min_values: 1,
                 max_values: 1
               )
    end

    test "creates a channel select menu with specific channel types" do
      assert %{
               type: 8,
               custom_id: "select_channel",
               # Text and voice channels
               channel_types: [0, 2],
               min_values: 1,
               max_values: 1
             } =
               Components.channel_select(
                 custom_id: "select_channel",
                 channel_types: [:guild_text, :guild_voice],
                 min_values: 1,
                 max_values: 1
               )
    end
  end

  describe "section/1" do
    test "creates a section with components and accessory" do
      components = [%{type: 10, content: "This is some text content"}]
      accessory = %{type: 11, media: %{url: "https://example.com/image.png"}}

      assert %{
               type: 9,
               components: ^components,
               accessory: ^accessory
             } =
               Components.section(
                 components: components,
                 accessory: accessory
               )
    end

    test "creates a section with id" do
      components = [%{type: 10, content: "This is some text content"}]
      accessory = %{type: 11, media: %{url: "https://example.com/image.png"}}

      assert %{
               type: 9,
               id: "intro_section",
               components: ^components,
               accessory: ^accessory
             } =
               Components.section(
                 id: "intro_section",
                 components: components,
                 accessory: accessory
               )
    end
  end

  describe "text_display/1" do
    test "creates a text display component" do
      assert %{
               type: 10,
               content: "This is some text content"
             } = Components.text_display(content: "This is some text content")
    end

    test "creates a text display component with id" do
      assert %{
               type: 10,
               id: "text_1",
               content: "This is some text content"
             } =
               Components.text_display(
                 id: "text_1",
                 content: "This is some text content"
               )
    end
  end

  describe "thumbnail/1" do
    test "creates a thumbnail with url string" do
      assert %{
               type: 11,
               media: %{url: "https://example.com/image.png"}
             } = Components.thumbnail(media: "https://example.com/image.png")
    end

    test "creates a thumbnail with description" do
      assert %{
               type: 11,
               media: %{url: "https://example.com/image.png"},
               description: "Example image"
             } =
               Components.thumbnail(
                 media: "https://example.com/image.png",
                 description: "Example image"
               )
    end

    test "creates a thumbnail marked as spoiler" do
      assert %{
               type: 11,
               media: %{url: "https://example.com/image.png"},
               spoiler: true
             } =
               Components.thumbnail(
                 media: "https://example.com/image.png",
                 spoiler: true
               )
    end
  end

  describe "container/1" do
    test "creates a container with components" do
      components = [%{type: 9, components: [], accessory: %{}}]

      assert %{
               type: 17,
               components: ^components
             } = Components.container(components: components)
    end

    test "creates a container with accent color as integer" do
      components = [%{type: 9, components: [], accessory: %{}}]

      assert %{
               type: 17,
               components: ^components,
               # 0xFF0000
               accent_color: 16_711_680
             } =
               Components.container(
                 components: components,
                 accent_color: 0xFF0000
               )
    end

    test "creates a container with accent color as hex string" do
      components = [%{type: 9, components: [], accessory: %{}}]

      assert %{
               type: 17,
               components: ^components,
               # 0xFF0000
               accent_color: 16_711_680
             } =
               Components.container(
                 components: components,
                 accent_color: "#FF0000"
               )
    end
  end
end
