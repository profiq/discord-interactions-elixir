# DiscordInteractions

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

