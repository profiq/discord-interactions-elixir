defmodule DiscordInteractions do
  @moduledoc """
  Documentation for `DiscordInteractions`.
  """

  defmacro interactions(do: block) do
    quote do
      def init do
        var!(interactions) = %{
          commands: [],
          message_component_handler: nil,
          modal_submit_handler: nil
        }
        unquote(block)
        var!(interactions)
      end
    end
  end

  defmacro application_command(_opts \\ [], do: block) do
    quote do
      var!(command) = %{
        definition: %{},
        handler: nil,
        guilds: []
      }
      unquote(block)
      var!(interactions) = %{var!(interactions) | commands: [var!(command) | var!(interactions).commands]}
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
      var!(command) = %{var!(command) | handler: unquote(handler)}
    end
  end

  defmacro message_component_handler(handler) do
    quote do
      var!(interactions) = %{var!(interactions) | message_component_handler: unquote(handler)}
    end
  end

  defmacro modal_submit_handler(handler) do
    quote do
      var!(interactions) = %{var!(interactions) | modal_submit_handler: unquote(handler)}
    end
  end
end
