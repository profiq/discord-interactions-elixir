# Discord Interactions

[![Version](https://img.shields.io/hexpm/v/discord_interactions.svg)](https://hex.pm/packages/discord_interactions)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/discord_interactions/)
[![Download](https://img.shields.io/hexpm/dt/discord_interactions.svg)](https://hex.pm/packages/discord_interactions)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

An [Elixir](http://elixir-lang.org/) library for handling Discord interaction webhooks, which can be used to implement application commands
with simple chat responses, as well as more complex user interfaces using [components](https://discord.com/developers/docs/components/overview).

DiscordInteractions includes:
* A plug for handling incoming interaction requests, which implements [security header validation](https://discord.com/developers/docs/interactions/overview#handling-interactions)
* Automatic registration of application commands with Discord at startup
* Discord REST API client
* Modules for generating interaction responses, and component and embed payloads

## Installation

The package can be installed by adding `discord_interactions` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:discord_interactions, "~> 0.1.0"}
  ]
end
```

### Setting Up a Command Handler

1. **Create a Discord module** that will handle your commands:

```elixir
defmodule YourApp.Discord do
  use DiscordInteractions

  # Always require Logger for proper error reporting
  require Logger

  # Import response helpers
  alias DiscordInteractions.InteractionResponse

  interactions do
    # Define a simple slash command
    application_command "hello" do
      description("Greets the user")
      handler(&hello/1)
    end
  end

  # Implement your command handler
  def hello(itx) do
    user_id = itx["member"]["user"]["id"]

    response =
      InteractionResponse.channel_message_with_source()
      |> InteractionResponse.content("Hello, <@#{user_id}>!")
      |> InteractionResponse.allowed_mentions(parse: [:users])

    {:ok, response}
  end
end
```

2. **Add the command registration to your application supervision tree**:

```elixir
# In your application.ex
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

3. **Add the Discord Interactions plug to your router**:

```elixir
# In your router.ex
defmodule YourAppWeb.Router do
  use YourAppWeb, :router

  # Other routes...

  # Route for Discord interactions
  forward "/discord", DiscordInteractions.Plug, YourApp.Discord
end
```

4. **Configure your endpoint** to cache the raw request body for signature verification:

```elixir
# In your endpoint.ex
plug Plug.Parsers,
  parsers: [:urlencoded, :multipart, :json],
  pass: ["*/*"],
  json_decoder: Phoenix.json_library(),
  body_reader: {DiscordInteractions.CacheBodyReader, :read_body, []}
```

5. **Set up environment variables** in your config:

```elixir
# In your config/runtime.exs or config/config.exs
config :discord_interactions,
  public_key: System.get_env("DISCORD_PUBLIC_KEY"),
  bot_token: System.get_env("DISCORD_BOT_TOKEN"),
  application_id: System.get_env("DISCORD_APPLICATION_ID")
```

Documentation can be found at <https://hexdocs.pm/discord_interactions>.

## Development

### Publishing to Hex.pm

This package is automatically published to [Hex.pm](https://hex.pm) when a new tag is pushed to the repository. The tag should follow the format `vX.Y.Z` (e.g., `v0.1.0`), and the version in the tag should match the version in `mix.exs`.

To publish a new version:

1. Update the version in `mix.exs`
2. Commit your changes
3. Create and push a new tag:
   ```bash
   git tag v0.1.0
   git push origin v0.1.0
   ```

The GitHub Action will automatically run tests and publish the package to Hex.pm if all tests pass.

**Note:** You need to set up the `HEX_API_KEY` secret in your GitHub repository settings. You can get your Hex.pm API key by running `mix hex.user key` or from your [Hex.pm dashboard](https://hex.pm/dashboard/keys).

