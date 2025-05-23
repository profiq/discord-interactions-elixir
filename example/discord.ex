defmodule ExampleWeb.Discord do
  @moduledoc """
  Example module showcasing Discord Interactions library features.

  This module demonstrates:
  1. A hello command that greets the user with a mention
  2. A modal command that shows a form and processes the input
  3. A color command with autocomplete functionality
  4. A component command showcasing various interactive elements
  5. A message command that counts characters in a message

  Add this module to your application by adding it to your application's supervision tree:

  ```elixir
  def start(_type, _args) do
    children = [
      # Other children...
      ExampleWeb.Endpoint,
      {DiscordInteractions.CommandRegistration, ExampleWeb.Discord}
    ]

    opts = [strategy: :one_for_one, name: ExampleWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end
  ```

  And add the Discord Interactions plug to your router:

  ```elixir
  defmodule ExampleWeb.Router do
    use ExampleWeb, :router

    # Other pipelines and routes...

    # Route for Discord interactions
    forward "/discord", DiscordInteractions.Plug, ExampleWeb.Discord
  end
  ```
  """

  alias DiscordInteractions.InteractionResponse
  alias DiscordInteractions.Embed

  use DiscordInteractions

  # Import component helpers
  import DiscordInteractions.Components

  require Logger

  interactions do
    # 1. Hello command - greets the user with a mention
    application_command "hello" do
      description("Greets you with a mention")
      handler(&hello/1)
    end

    # 2. Modal command - shows a form and processes the input
    application_command "modal" do
      description("Shows a modal form for user input")
      handler(&modal/1)
    end

    # 3. Color command - with autocomplete functionality
    application_command "color" do
      description("Shows an embed with the selected color")

      option("color", :string,
        description: "Color name or hex code",
        autocomplete: true,
        required: true
      )

      handler(&color/1)
      autocomplete_handler(&color_autocomplete/1)
    end

    # 4. Component command - showcases various interactive elements
    application_command "components" do
      description("Demonstrates various interactive components")
      handler(&components/1)
    end

    # 5. Message command - counts characters in a message
    application_command "Count Characters", :message do
      handler(&count_characters/1)
    end

    # Set up handlers for component interactions and modal submissions
    message_component_handler(&handle_component/1)
    modal_submit_handler(&handle_modal_submit/1)
  end

  #
  # Command Handlers
  #

  @doc """
  Handler for the hello command.
  Greets the user with a mention.
  """
  def hello(%{"member" => %{"user" => %{"id" => user_id}}}) do
    response =
      InteractionResponse.channel_message_with_source()
      |> InteractionResponse.content("Hello, <@#{user_id}>!")
      |> InteractionResponse.allowed_mentions(parse: [:users])

    {:ok, response}
  end

  # Fallback for DM channels where member is not present
  def hello(%{"user" => %{"id" => user_id}}) do
    response =
      InteractionResponse.channel_message_with_source()
      |> InteractionResponse.content("Hello, <@#{user_id}>!")
      |> InteractionResponse.allowed_mentions(parse: [:users])

    {:ok, response}
  end

  @doc """
  Handler for the modal command.
  Shows a modal form for user input.
  """
  def modal(_interaction) do
    response =
      InteractionResponse.modal()
      |> InteractionResponse.title("User Information")
      |> InteractionResponse.custom_id("user_info_modal")
      |> InteractionResponse.components([
        action_row(
          components: [
            text_input(
              custom_id: "name",
              label: "Your Name",
              style: :short,
              placeholder: "Enter your name",
              required: true
            )
          ]
        ),
        action_row(
          components: [
            text_input(
              custom_id: "bio",
              label: "About You",
              style: :paragraph,
              placeholder: "Tell us about yourself",
              min_length: 10,
              max_length: 300
            )
          ]
        ),
        action_row(
          components: [
            text_input(
              custom_id: "favorite_color",
              label: "Favorite Color",
              style: :short,
              placeholder: "e.g., Blue, Red, #00FF00"
            )
          ]
        )
      ])

    {:ok, response}
  end

  @doc """
  Handler for the color command.
  Shows an embed with the selected color.
  """
  def color(%{"data" => %{"options" => options}}) do
    # Extract the color value from options
    color_value =
      Enum.find_value(options, "", fn opt ->
        if opt["name"] == "color", do: opt["value"]
      end)

    # Convert color name to hex if it's a named color
    {color_name, color_hex} = get_color_info(color_value)

    # Create an embed with the selected color
    embed =
      Embed.new()
      |> Embed.title("Color: #{color_name}")
      |> Embed.description("Hex code: `#{color_hex}`")
      |> Embed.color(parse_hex_color(color_hex))

    response =
      InteractionResponse.channel_message_with_source()
      |> InteractionResponse.embeds([embed])

    {:ok, response}
  end

  @doc """
  Handler for the component command.
  Demonstrates various interactive components.
  """
  def components(_interaction) do
    # Create action row with buttons
    buttons_row =
      action_row(
        components: [
          button(
            style: :primary,
            label: "Primary Button",
            custom_id: "primary_button"
          ),
          button(
            style: :success,
            label: "Success Button",
            custom_id: "success_button"
          ),
          button(
            style: :danger,
            label: "Danger Button",
            custom_id: "danger_button"
          ),
          button(
            style: :link,
            label: "GitHub",
            url: "https://github.com"
          )
        ]
      )

    # Create action row with a select menu
    select_row =
      action_row(
        components: [
          string_select(
            custom_id: "color_select",
            placeholder: "Select a color",
            options: [
              select_option(label: "Red", value: "red", description: "The color red"),
              select_option(label: "Green", value: "green", description: "The color green"),
              select_option(label: "Blue", value: "blue", description: "The color blue")
            ],
            min_values: 1,
            max_values: 1
          )
        ]
      )

    # Create action row with user select
    user_select_row =
      action_row(
        components: [
          user_select(
            custom_id: "user_select",
            placeholder: "Select a user",
            min_values: 1,
            max_values: 1
          )
        ]
      )

    response =
      InteractionResponse.channel_message_with_source()
      |> InteractionResponse.content("Here are some interactive components:")
      |> InteractionResponse.components([buttons_row, select_row, user_select_row])

    {:ok, response}
  end

  @doc """
  Handler for the Count Characters message command.
  Counts characters in a message and sends an ephemeral response.
  """
  def count_characters(%{
        "data" => %{"resolved" => %{"messages" => messages}, "target_id" => message_id}
      }) do
    # Get the message content from the resolved data
    message = messages[message_id]
    content = message["content"] || ""

    # Count characters, words, and lines
    char_count = String.length(content)
    word_count = content |> String.split(~r/\s+/, trim: true) |> length()
    line_count = content |> String.split("\n") |> length()

    # Create an embed with the message statistics
    embed =
      Embed.new()
      |> Embed.title("Message Statistics")
      |> Embed.description("Analysis of the selected message")
      |> Embed.add_field("Characters", "#{char_count}", true)
      |> Embed.add_field("Words", "#{word_count}", true)
      |> Embed.add_field("Lines", "#{line_count}", true)
      # Discord Blurple color
      |> Embed.color(0x5865F2)

    # Create an ephemeral response (only visible to the command user)
    response =
      InteractionResponse.channel_message_with_source()
      |> InteractionResponse.embeds([embed])
      |> InteractionResponse.ephemeral()

    {:ok, response}
  end

  #
  # Autocomplete Handlers
  #

  @doc """
  Autocomplete handler for the color command.
  Provides color suggestions as the user types.
  """
  def color_autocomplete(%{"data" => %{"options" => options}}) do
    # Get the current input value
    focused_option = Enum.find(options, fn opt -> opt["focused"] == true end)
    current_input = String.downcase(focused_option["value"] || "")

    # Filter colors based on the current input
    suggestions =
      get_color_list()
      |> Enum.filter(fn {name, hex} ->
        String.contains?(String.downcase(name), current_input) or
          String.contains?(String.downcase(hex), current_input)
      end)
      # Discord limits to 25 choices
      |> Enum.take(25)
      |> Enum.map(fn {name, hex} ->
        InteractionResponse.choice("#{name} (#{hex})", name)
      end)

    response = InteractionResponse.application_command_autocomplete_result(suggestions)

    {:ok, response}
  end

  #
  # Component and Modal Handlers
  #

  @doc """
  Handler for component interactions.
  Processes button clicks and select menu choices.
  """
  def handle_component(%{"data" => %{"custom_id" => "primary_button"}} = _interaction) do
    response =
      InteractionResponse.channel_message_with_source()
      |> InteractionResponse.content("You clicked the Primary button!")

    {:ok, response}
  end

  def handle_component(%{"data" => %{"custom_id" => "success_button"}} = _interaction) do
    response =
      InteractionResponse.channel_message_with_source()
      |> InteractionResponse.content("You clicked the Success button!")

    {:ok, response}
  end

  def handle_component(%{"data" => %{"custom_id" => "danger_button"}} = _interaction) do
    response =
      InteractionResponse.channel_message_with_source()
      |> InteractionResponse.content("You clicked the Danger button!")

    {:ok, response}
  end

  def handle_component(
        %{"data" => %{"custom_id" => "color_select", "values" => [color]}} = _interaction
      ) do
    {color_name, color_hex} = get_color_info(color)

    embed =
      Embed.new()
      |> Embed.title("Selected Color: #{color_name}")
      |> Embed.description("Hex code: `#{color_hex}`")
      |> Embed.color(parse_hex_color(color_hex))

    response =
      InteractionResponse.channel_message_with_source()
      |> InteractionResponse.embeds([embed])

    {:ok, response}
  end

  def handle_component(
        %{
          "data" => %{
            "custom_id" => "user_select",
            "resolved" => %{"users" => users},
            "values" => [user_id]
          }
        } = _interaction
      ) do
    user = users[user_id]

    response =
      InteractionResponse.channel_message_with_source()
      |> InteractionResponse.content("You selected user: <@#{user_id}> (#{user["username"]})")
      # Don't ping the user
      |> InteractionResponse.allowed_mentions(parse: [])

    {:ok, response}
  end

  # Fallback for any other component interactions
  def handle_component(_interaction) do
    response =
      InteractionResponse.channel_message_with_source()
      |> InteractionResponse.content("You interacted with a component!")

    {:ok, response}
  end

  @doc """
  Handler for modal submissions.
  Processes form data submitted through modals.
  """
  def handle_modal_submit(%{
        "data" => %{"custom_id" => "user_info_modal", "components" => components}
      }) do
    # Extract values from the modal components
    values = extract_modal_values(components)

    # Create an embed with the submitted information
    embed =
      Embed.new()
      |> Embed.title("User Information")
      |> Embed.add_field("Name", values["name"] || "Not provided", true)
      |> Embed.add_field("Favorite Color", values["favorite_color"] || "Not provided", true)
      |> Embed.add_field("Bio", values["bio"] || "Not provided", false)

    response =
      InteractionResponse.channel_message_with_source()
      |> InteractionResponse.content("Thanks for submitting your information!")
      |> InteractionResponse.embeds([embed])

    {:ok, response}
  end

  # Fallback for any other modal submissions
  def handle_modal_submit(_interaction) do
    response =
      InteractionResponse.channel_message_with_source()
      |> InteractionResponse.content("Modal submitted!")

    {:ok, response}
  end

  #
  # Helper Functions
  #

  @doc """
  Extracts values from modal components.
  """
  def extract_modal_values(components) do
    Enum.reduce(components, %{}, fn component, acc ->
      Enum.reduce(component["components"], acc, fn input, acc ->
        Map.put(acc, input["custom_id"], input["value"])
      end)
    end)
  end

  @doc """
  Gets color information (name and hex) for a given color value.
  """
  def get_color_info(color_value) do
    color_map = Map.new(get_color_list())

    case Map.get(color_map, color_value) do
      # If not a named color, assume it's a hex code
      nil -> {color_value, color_value}
      # If it's a named color, return the hex
      hex -> {color_value, hex}
    end
  end

  @doc """
  Parses a hex color string into an integer.
  """
  def parse_hex_color("#" <> hex), do: parse_hex_color(hex)

  def parse_hex_color(hex) do
    {color_int, _} = Integer.parse(hex, 16)
    color_int
  end

  @doc """
  Returns a list of common colors with their hex codes.
  """
  def get_color_list do
    [
      {"Red", "#FF0000"},
      {"Green", "#00FF00"},
      {"Blue", "#0000FF"},
      {"Yellow", "#FFFF00"},
      {"Cyan", "#00FFFF"},
      {"Magenta", "#FF00FF"},
      {"Black", "#000000"},
      {"White", "#FFFFFF"},
      {"Gray", "#808080"},
      {"Orange", "#FFA500"},
      {"Purple", "#800080"},
      {"Pink", "#FFC0CB"},
      {"Brown", "#A52A2A"},
      {"Lime", "#00FF00"},
      {"Teal", "#008080"},
      {"Navy", "#000080"},
      {"Olive", "#808000"},
      {"Maroon", "#800000"},
      {"Aqua", "#00FFFF"},
      {"Silver", "#C0C0C0"},
      {"Gold", "#FFD700"},
      {"Indigo", "#4B0082"},
      {"Violet", "#EE82EE"},
      {"Turquoise", "#40E0D0"},
      {"Coral", "#FF7F50"}
    ]
  end
end
