defmodule DiscordInteractions.EmbedTest do
  use ExUnit.Case
  doctest DiscordInteractions.Embed

  alias DiscordInteractions.Embed

  describe "new/1" do
    test "creates an empty embed" do
      assert %{} = Embed.new()
    end

    test "creates an embed with initial values" do
      assert %{title: "Hello", description: "World"} =
               Embed.new(title: "Hello", description: "World")
    end
  end

  describe "title/2" do
    test "sets the title" do
      embed = Embed.new()
      assert %{title: "Hello, World!"} = Embed.title(embed, "Hello, World!")
    end
  end

  describe "description/2" do
    test "sets the description" do
      embed = Embed.new()

      assert %{description: "This is a description"} =
               Embed.description(embed, "This is a description")
    end
  end

  describe "url/2" do
    test "sets the url" do
      embed = Embed.new()
      assert %{url: "https://example.com"} = Embed.url(embed, "https://example.com")
    end
  end

  describe "timestamp/2" do
    test "sets the timestamp from string" do
      embed = Embed.new()
      assert %{timestamp: "2023-01-01T12:00:00Z"} = Embed.timestamp(embed, "2023-01-01T12:00:00Z")
    end

    test "sets the timestamp from DateTime" do
      embed = Embed.new()
      timestamp = DateTime.from_naive!(~N[2023-01-01 12:00:00], "Etc/UTC")
      assert %{timestamp: "2023-01-01T12:00:00Z"} = Embed.timestamp(embed, timestamp)
    end
  end

  describe "color/2" do
    test "sets the color from integer" do
      embed = Embed.new()
      assert %{color: 65280} = Embed.color(embed, 0x00FF00)
    end

    test "sets the color from hex string" do
      embed = Embed.new()
      assert %{color: 65280} = Embed.color(embed, "#00FF00")
    end
  end

  describe "footer/3" do
    test "sets the footer with text only" do
      embed = Embed.new()
      assert %{footer: %{text: "Footer text"}} = Embed.footer(embed, "Footer text")
    end

    test "sets the footer with text and icon_url" do
      embed = Embed.new()

      assert %{footer: %{text: "Footer text", icon_url: "https://example.com/icon.png"}} =
               Embed.footer(embed, "Footer text", "https://example.com/icon.png")
    end

    test "sets the footer with all parameters" do
      embed = Embed.new()

      assert %{
               footer: %{
                 text: "Footer text",
                 icon_url: "https://example.com/icon.png",
                 proxy_icon_url: "https://proxy.example.com/icon.png"
               }
             } =
               Embed.footer(
                 embed,
                 "Footer text",
                 "https://example.com/icon.png",
                 "https://proxy.example.com/icon.png"
               )
    end
  end

  describe "image/3" do
    test "sets the image with url only" do
      embed = Embed.new()

      assert %{image: %{url: "https://example.com/image.png"}} =
               Embed.image(embed, "https://example.com/image.png")
    end

    test "sets the image with all parameters" do
      embed = Embed.new()

      assert %{
               image: %{
                 url: "https://example.com/image.png",
                 proxy_url: "https://proxy.example.com/image.png",
                 height: 300,
                 width: 400
               }
             } =
               Embed.image(embed, "https://example.com/image.png",
                 proxy_url: "https://proxy.example.com/image.png",
                 height: 300,
                 width: 400
               )
    end
  end

  describe "thumbnail/3" do
    test "sets the thumbnail with url only" do
      embed = Embed.new()

      assert %{thumbnail: %{url: "https://example.com/thumbnail.png"}} =
               Embed.thumbnail(embed, "https://example.com/thumbnail.png")
    end

    test "sets the thumbnail with all parameters" do
      embed = Embed.new()

      assert %{
               thumbnail: %{
                 url: "https://example.com/thumbnail.png",
                 proxy_url: "https://proxy.example.com/thumbnail.png",
                 height: 100,
                 width: 100
               }
             } =
               Embed.thumbnail(embed, "https://example.com/thumbnail.png",
                 proxy_url: "https://proxy.example.com/thumbnail.png",
                 height: 100,
                 width: 100
               )
    end
  end

  describe "video/3" do
    test "sets the video with url only" do
      embed = Embed.new()

      assert %{video: %{url: "https://example.com/video.mp4"}} =
               Embed.video(embed, "https://example.com/video.mp4")
    end

    test "sets the video with all parameters" do
      embed = Embed.new()

      assert %{
               video: %{
                 url: "https://example.com/video.mp4",
                 height: 720,
                 width: 1280
               }
             } =
               Embed.video(embed, "https://example.com/video.mp4",
                 height: 720,
                 width: 1280
               )
    end
  end

  describe "provider/3" do
    test "sets the provider with name only" do
      embed = Embed.new()

      assert %{provider: %{name: "Example Provider"}} =
               Embed.provider(embed, "Example Provider")
    end

    test "sets the provider with name and url" do
      embed = Embed.new()

      assert %{provider: %{name: "Example Provider", url: "https://example.com"}} =
               Embed.provider(embed, "Example Provider", "https://example.com")
    end
  end

  describe "author/5" do
    test "sets the author with name only" do
      embed = Embed.new()
      assert %{author: %{name: "John Doe"}} = Embed.author(embed, "John Doe")
    end

    test "sets the author with name and url" do
      embed = Embed.new()

      assert %{author: %{name: "John Doe", url: "https://example.com"}} =
               Embed.author(embed, "John Doe", "https://example.com")
    end

    test "sets the author with name, url, and icon_url" do
      embed = Embed.new()

      assert %{
               author: %{
                 name: "John Doe",
                 url: "https://example.com",
                 icon_url: "https://example.com/icon.png"
               }
             } =
               Embed.author(
                 embed,
                 "John Doe",
                 "https://example.com",
                 "https://example.com/icon.png"
               )
    end

    test "sets the author with all parameters" do
      embed = Embed.new()

      assert %{
               author: %{
                 name: "John Doe",
                 url: "https://example.com",
                 icon_url: "https://example.com/icon.png",
                 proxy_icon_url: "https://proxy.example.com/icon.png"
               }
             } =
               Embed.author(
                 embed,
                 "John Doe",
                 "https://example.com",
                 "https://example.com/icon.png",
                 "https://proxy.example.com/icon.png"
               )
    end
  end

  describe "add_field/4" do
    test "adds a field with default inline value" do
      embed = Embed.new()

      assert %{fields: [%{name: "Name", value: "Value", inline: false}]} =
               Embed.add_field(embed, "Name", "Value")
    end

    test "adds a field with inline set to true" do
      embed = Embed.new()

      assert %{fields: [%{name: "Name", value: "Value", inline: true}]} =
               Embed.add_field(embed, "Name", "Value", true)
    end

    test "appends a field to an embed with existing fields" do
      embed = Embed.new() |> Embed.add_field("Field 1", "Value 1")

      assert %{
               fields: [
                 %{name: "Field 1", value: "Value 1", inline: false},
                 %{name: "Field 2", value: "Value 2", inline: true}
               ]
             } = Embed.add_field(embed, "Field 2", "Value 2", true)
    end
  end

  describe "function chaining for basic properties" do
    test "can chain title, description and color functions" do
      embed =
        Embed.new()
        |> Embed.title("Hello, World!")
        |> Embed.description("This is a description")
        |> Embed.color(0x00FF00)

      assert %{
               title: "Hello, World!",
               description: "This is a description",
               color: 65280
             } = embed
    end
  end

  describe "function chaining with complex properties" do
    test "can chain footer and field functions" do
      embed =
        Embed.new()
        |> Embed.footer("Footer text")
        |> Embed.add_field("Field 1", "Value 1", true)
        |> Embed.add_field("Field 2", "Value 2")

      assert %{
               footer: %{text: "Footer text"},
               fields: [
                 %{name: "Field 1", value: "Value 1", inline: true},
                 %{name: "Field 2", value: "Value 2", inline: false}
               ]
             } = embed
    end
  end
end
