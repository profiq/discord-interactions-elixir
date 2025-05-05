defmodule DiscordInteractions do
  @moduledoc """
  Documentation for `DiscordInteractions`.
  """

  defmacro discord_commands(do: block) do
    quote do
      def init do
        var!(commands) = []
        unquote(block)
        var!(commands)
      end
    end
  end

  defmacro command(_opts \\ [], do: block) do
    quote do
      var!(command) = %{
        definition: %{},
        handlers: %{
          application_command: nil,
          message_component: nil,
          application_command_autocomplete: nil,
          modal_submit: nil
        },
        guilds: []
      }
      unquote(block)
      var!(commands) = [var!(command) | var!(commands)]
    end
  end

  defmacro name(name) do
    quote do
      var!(command) = %{var!(command) | definition: Map.put(var!(command).definition, :name, unquote(name))}
    end
  end

  defmacro description(description) do
    quote do
      var!(command) = %{var!(command) | definition: Map.put(var!(command).definition, :description, unquote(description))}
    end
  end

  defmacro properties(properties) do
    quote do
      var!(command) = %{var!(command) | definition: Map.merge(var!(command).definition, unquote(properties))}
    end
  end

  defmacro guild(guild) do
    quote do
      var!(command) = %{var!(command) | guilds: [unquote(guild) | var!(command).guilds]}
    end
  end

  defmacro handler(handler) do
    quote do
      var!(command) = %{var!(command) | handlers: %{var!(command).handlers | application_command: unquote(handler)}}
    end
  end

  defmacro component_handler(handler) do
    quote do
      var!(command) = %{var!(command) | handlers: %{var!(command).handlers | message_component: unquote(handler)}}
    end
  end

  defmacro autocomplete_handler(handler) do
    quote do
      var!(command) = %{var!(command) | handlers: %{var!(command).handlers | application_command_autocomplete: unquote(handler)}}
    end
  end

  defmacro modal_submit_handler(handler) do
    quote do
      var!(command) = %{var!(command) | handlers: %{var!(command).handlers | modal_submit: unquote(handler)}}
    end
  end
end
