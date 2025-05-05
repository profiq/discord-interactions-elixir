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
      var!(command) = %{}
      unquote(block)
      var!(commands) = [var!(command) | var!(commands)]
    end
  end

  defmacro name(name) do
    quote do
      var!(command) = Map.put(var!(command), :name, unquote(name))
    end
  end

  defmacro description(description) do
    quote do
      var!(command) = Map.put(var!(command), :description, unquote(description))
    end
  end

  defmacro properties(properties) do
    quote do
      var!(command) = Map.merge(var!(command), unquote(properties))
    end
  end
end
