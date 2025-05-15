defmodule DiscordInteractions.Embed do
  @moduledoc """
  Helper module for creating Discord embed objects.

  This module provides functions for creating and manipulating Discord embed objects
  as defined in the Discord API documentation:
  https://discord.com/developers/docs/resources/channel#embed-object

  Embeds are rich content blocks that can contain formatted text, images, fields, and more.
  They can be used in messages sent by bots and webhooks.

  ## Embed Structure

  An embed object can have the following fields:
  - `title`: Title of the embed (up to 256 characters)
  - `description`: Description of the embed (up to 4096 characters)
  - `url`: URL for the embed title to link to
  - `timestamp`: ISO8601 timestamp for the embed footer
  - `color`: Color code of the embed (as an integer or hex string)
  - `footer`: Footer information (text, icon URL)
  - `image`: Image information (URL, dimensions)
  - `thumbnail`: Thumbnail information (URL, dimensions)
  - `video`: Video information (URL, dimensions)
  - `provider`: Provider information (name, URL)
  - `author`: Author information (name, URL, icon URL)
  - `fields`: Array of field objects (name, value, inline)

  ## Examples

      # Create a basic embed
      embed = DiscordInteractions.Embed.new()
              |> DiscordInteractions.Embed.title("Hello, World!")
              |> DiscordInteractions.Embed.description("This is an embed description")
              |> DiscordInteractions.Embed.color(0x00FF00)

      # Create an embed with fields
      embed = DiscordInteractions.Embed.new()
              |> DiscordInteractions.Embed.title("User Profile")
              |> DiscordInteractions.Embed.add_field("Name", "John Doe", true)
              |> DiscordInteractions.Embed.add_field("Age", "30", true)
              |> DiscordInteractions.Embed.add_field("Bio", "Lorem ipsum dolor sit amet")

      # Create an embed with author and footer
      embed = DiscordInteractions.Embed.new()
              |> DiscordInteractions.Embed.title("News Update")
              |> DiscordInteractions.Embed.description("Breaking news!")
              |> DiscordInteractions.Embed.author("News Bot", "https://example.com", "https://example.com/icon.png")
              |> DiscordInteractions.Embed.footer("Posted at 12:00 PM", "https://example.com/footer-icon.png")
  """

  @type t :: %{
    optional(:title) => String.t(),
    optional(:description) => String.t(),
    optional(:url) => String.t(),
    optional(:timestamp) => String.t(),
    optional(:color) => integer(),
    optional(:footer) => map(),
    optional(:image) => map(),
    optional(:thumbnail) => map(),
    optional(:video) => map(),
    optional(:provider) => map(),
    optional(:author) => map(),
    optional(:fields) => [map()]
  }

  @doc """
  Creates a new empty embed object.

  ## Examples

      iex> DiscordInteractions.Embed.new()
      %{}

      iex> DiscordInteractions.Embed.new(title: "Hello", description: "World")
      %{title: "Hello", description: "World"}
  """
  @spec new(keyword()) :: t()
  def new(opts \\ []) do
    Enum.reduce(opts, %{}, fn {key, value}, acc ->
      Map.put(acc, key, value)
    end)
  end

  @doc """
  Sets the title of an embed.

  ## Parameters
  - `embed`: The embed to modify
  - `title`: The title text (up to 256 characters)

  ## Examples

      iex> embed = DiscordInteractions.Embed.new()
      iex> DiscordInteractions.Embed.title(embed, "Hello, World!")
      %{title: "Hello, World!"}
  """
  @spec title(t(), String.t()) :: t()
  def title(embed, title) when is_binary(title) do
    Map.put(embed, :title, title)
  end

  @doc """
  Sets the description of an embed.

  ## Parameters
  - `embed`: The embed to modify
  - `description`: The description text (up to 4096 characters)

  ## Examples

      iex> embed = DiscordInteractions.Embed.new()
      iex> DiscordInteractions.Embed.description(embed, "This is a description")
      %{description: "This is a description"}
  """
  @spec description(t(), String.t()) :: t()
  def description(embed, description) when is_binary(description) do
    Map.put(embed, :description, description)
  end

  @doc """
  Sets the URL of an embed.

  ## Parameters
  - `embed`: The embed to modify
  - `url`: The URL for the embed title to link to

  ## Examples

      iex> embed = DiscordInteractions.Embed.new()
      iex> DiscordInteractions.Embed.url(embed, "https://example.com")
      %{url: "https://example.com"}
  """
  @spec url(t(), String.t()) :: t()
  def url(embed, url) when is_binary(url) do
    Map.put(embed, :url, url)
  end

  @doc """
  Sets the timestamp of an embed.

  ## Parameters
  - `embed`: The embed to modify
  - `timestamp`: The timestamp as a DateTime or ISO8601 string

  ## Examples

      iex> embed = DiscordInteractions.Embed.new()
      iex> DiscordInteractions.Embed.timestamp(embed, "2023-01-01T12:00:00Z")
      %{timestamp: "2023-01-01T12:00:00Z"}

      iex> embed = DiscordInteractions.Embed.new()
      iex> timestamp = DateTime.from_naive!(~N[2023-01-01 12:00:00], "Etc/UTC")
      iex> DiscordInteractions.Embed.timestamp(embed, timestamp)
      %{timestamp: "2023-01-01T12:00:00Z"}
  """
  @spec timestamp(t(), String.t() | DateTime.t()) :: t()
  def timestamp(embed, timestamp) when is_binary(timestamp) do
    Map.put(embed, :timestamp, timestamp)
  end

  def timestamp(embed, %DateTime{} = timestamp) do
    Map.put(embed, :timestamp, DateTime.to_iso8601(timestamp))
  end

  @doc """
  Sets the color of an embed.

  ## Parameters
  - `embed`: The embed to modify
  - `color`: The color as an integer or hex string

  ## Examples

      iex> embed = DiscordInteractions.Embed.new()
      iex> DiscordInteractions.Embed.color(embed, 0x00FF00)
      %{color: 65280}

      iex> embed = DiscordInteractions.Embed.new()
      iex> DiscordInteractions.Embed.color(embed, "#00FF00")
      %{color: 65280}
  """
  @spec color(t(), integer() | String.t()) :: t()
  def color(embed, color) when is_integer(color) do
    Map.put(embed, :color, color)
  end

  def color(embed, "#" <> hex_color) do
    {color, _} = Integer.parse(hex_color, 16)
    Map.put(embed, :color, color)
  end

  @doc """
  Sets the footer of an embed.

  ## Parameters
  - `embed`: The embed to modify
  - `text`: The footer text (up to 2048 characters)
  - `icon_url`: Optional URL of the footer icon
  - `proxy_icon_url`: Optional proxied URL of the footer icon

  ## Examples

      iex> embed = DiscordInteractions.Embed.new()
      iex> DiscordInteractions.Embed.footer(embed, "Footer text")
      %{footer: %{text: "Footer text"}}

      iex> embed = DiscordInteractions.Embed.new()
      iex> DiscordInteractions.Embed.footer(embed, "Footer text", "https://example.com/icon.png")
      %{footer: %{text: "Footer text", icon_url: "https://example.com/icon.png"}}
  """
  @spec footer(t(), String.t(), String.t() | nil, String.t() | nil) :: t()
  def footer(embed, text, icon_url \\ nil, proxy_icon_url \\ nil) when is_binary(text) do
    footer = %{text: text}
    footer = if icon_url, do: Map.put(footer, :icon_url, icon_url), else: footer
    footer = if proxy_icon_url, do: Map.put(footer, :proxy_icon_url, proxy_icon_url), else: footer

    Map.put(embed, :footer, footer)
  end

  @doc """
  Sets the image of an embed.

  ## Parameters
  - `embed`: The embed to modify
  - `url`: URL of the image
  - `opts`: Optional parameters (proxy_url, height, width)

  ## Examples

      iex> embed = DiscordInteractions.Embed.new()
      iex> DiscordInteractions.Embed.image(embed, "https://example.com/image.png")
      %{image: %{url: "https://example.com/image.png"}}

      iex> embed = DiscordInteractions.Embed.new()
      iex> DiscordInteractions.Embed.image(embed, "https://example.com/image.png", proxy_url: "https://proxy.example.com/image.png", height: 300, width: 400)
      %{image: %{url: "https://example.com/image.png", proxy_url: "https://proxy.example.com/image.png", height: 300, width: 400}}
  """
  @spec image(t(), String.t(), keyword()) :: t()
  def image(embed, url, opts \\ []) when is_binary(url) do
    image = %{url: url}
    image = if opts[:proxy_url], do: Map.put(image, :proxy_url, opts[:proxy_url]), else: image
    image = if opts[:height], do: Map.put(image, :height, opts[:height]), else: image
    image = if opts[:width], do: Map.put(image, :width, opts[:width]), else: image

    Map.put(embed, :image, image)
  end

  @doc """
  Sets the thumbnail of an embed.

  ## Parameters
  - `embed`: The embed to modify
  - `url`: URL of the thumbnail
  - `opts`: Optional parameters (proxy_url, height, width)

  ## Examples

      iex> embed = DiscordInteractions.Embed.new()
      iex> DiscordInteractions.Embed.thumbnail(embed, "https://example.com/thumbnail.png")
      %{thumbnail: %{url: "https://example.com/thumbnail.png"}}

      iex> embed = DiscordInteractions.Embed.new()
      iex> DiscordInteractions.Embed.thumbnail(embed, "https://example.com/thumbnail.png", proxy_url: "https://proxy.example.com/thumbnail.png", height: 100, width: 100)
      %{thumbnail: %{url: "https://example.com/thumbnail.png", proxy_url: "https://proxy.example.com/thumbnail.png", height: 100, width: 100}}
  """
  @spec thumbnail(t(), String.t(), keyword()) :: t()
  def thumbnail(embed, url, opts \\ []) when is_binary(url) do
    thumbnail = %{url: url}
    thumbnail = if opts[:proxy_url], do: Map.put(thumbnail, :proxy_url, opts[:proxy_url]), else: thumbnail
    thumbnail = if opts[:height], do: Map.put(thumbnail, :height, opts[:height]), else: thumbnail
    thumbnail = if opts[:width], do: Map.put(thumbnail, :width, opts[:width]), else: thumbnail

    Map.put(embed, :thumbnail, thumbnail)
  end

  @doc """
  Sets the video of an embed.

  ## Parameters
  - `embed`: The embed to modify
  - `url`: URL of the video
  - `opts`: Optional parameters (proxy_url, height, width)

  ## Examples

      iex> embed = DiscordInteractions.Embed.new()
      iex> DiscordInteractions.Embed.video(embed, "https://example.com/video.mp4")
      %{video: %{url: "https://example.com/video.mp4"}}

      iex> embed = DiscordInteractions.Embed.new()
      iex> DiscordInteractions.Embed.video(embed, "https://example.com/video.mp4", height: 720, width: 1280)
      %{video: %{url: "https://example.com/video.mp4", height: 720, width: 1280}}
  """
  @spec video(t(), String.t(), keyword()) :: t()
  def video(embed, url, opts \\ []) when is_binary(url) do
    video = %{url: url}
    video = if opts[:proxy_url], do: Map.put(video, :proxy_url, opts[:proxy_url]), else: video
    video = if opts[:height], do: Map.put(video, :height, opts[:height]), else: video
    video = if opts[:width], do: Map.put(video, :width, opts[:width]), else: video

    Map.put(embed, :video, video)
  end

  @doc """
  Sets the provider of an embed.

  ## Parameters
  - `embed`: The embed to modify
  - `name`: Name of the provider
  - `url`: URL of the provider

  ## Examples

      iex> embed = DiscordInteractions.Embed.new()
      iex> DiscordInteractions.Embed.provider(embed, "Example Provider")
      %{provider: %{name: "Example Provider"}}

      iex> embed = DiscordInteractions.Embed.new()
      iex> DiscordInteractions.Embed.provider(embed, "Example Provider", "https://example.com")
      %{provider: %{name: "Example Provider", url: "https://example.com"}}
  """
  @spec provider(t(), String.t(), String.t() | nil) :: t()
  def provider(embed, name, url \\ nil) when is_binary(name) do
    provider = %{name: name}
    provider = if url, do: Map.put(provider, :url, url), else: provider

    Map.put(embed, :provider, provider)
  end

  @doc """
  Sets the author of an embed.

  ## Parameters
  - `embed`: The embed to modify
  - `name`: Name of the author
  - `url`: Optional URL of the author
  - `icon_url`: Optional URL of the author icon
  - `proxy_icon_url`: Optional proxied URL of the author icon

  ## Examples

      iex> embed = DiscordInteractions.Embed.new()
      iex> DiscordInteractions.Embed.author(embed, "John Doe")
      %{author: %{name: "John Doe"}}

      iex> embed = DiscordInteractions.Embed.new()
      iex> DiscordInteractions.Embed.author(embed, "John Doe", "https://example.com", "https://example.com/icon.png")
      %{author: %{name: "John Doe", url: "https://example.com", icon_url: "https://example.com/icon.png"}}
  """
  @spec author(t(), String.t(), String.t() | nil, String.t() | nil, String.t() | nil) :: t()
  def author(embed, name, url \\ nil, icon_url \\ nil, proxy_icon_url \\ nil) when is_binary(name) do
    author = %{name: name}
    author = if url, do: Map.put(author, :url, url), else: author
    author = if icon_url, do: Map.put(author, :icon_url, icon_url), else: author
    author = if proxy_icon_url, do: Map.put(author, :proxy_icon_url, proxy_icon_url), else: author

    Map.put(embed, :author, author)
  end

  @doc """
  Adds a field to an embed.

  ## Parameters
  - `embed`: The embed to modify
  - `name`: The name of the field (up to 256 characters)
  - `value`: The value of the field (up to 1024 characters)
  - `inline`: Whether the field should be displayed inline (default: false)

  ## Examples

      iex> embed = DiscordInteractions.Embed.new()
      iex> DiscordInteractions.Embed.add_field(embed, "Name", "Value")
      %{fields: [%{name: "Name", value: "Value", inline: false}]}

      iex> embed = DiscordInteractions.Embed.new()
      iex> DiscordInteractions.Embed.add_field(embed, "Name", "Value", true)
      %{fields: [%{name: "Name", value: "Value", inline: true}]}

      iex> embed = DiscordInteractions.Embed.new() |> DiscordInteractions.Embed.add_field("Field 1", "Value 1")
      iex> DiscordInteractions.Embed.add_field(embed, "Field 2", "Value 2")
      %{fields: [%{name: "Field 1", value: "Value 1", inline: false}, %{name: "Field 2", value: "Value 2", inline: false}]}
  """
  @spec add_field(t(), String.t(), String.t(), boolean()) :: t()
  def add_field(embed, name, value, inline \\ false) when is_binary(name) and is_binary(value) do
    field = %{name: name, value: value, inline: inline}
    fields = Map.get(embed, :fields, [])
    Map.put(embed, :fields, fields ++ [field])
  end
end
