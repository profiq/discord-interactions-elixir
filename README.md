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

