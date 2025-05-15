defmodule DiscordInteractions do
  @moduledoc """
  Documentation for `DiscordInteractions`.
  """

  @type guild :: String.t()

  @type command :: %{
          definition: map(),
          handler: function() | nil,
          autocomplete_handler: function() | nil,
          guilds: list(String.t())
        }

  @type config :: %{
          global_commands: %{String.t() => command},
          guild_commands: %{{guild, String.t()} => command},
          message_component_handler: function() | nil,
          modal_submit_handler: function() | nil
        }

  @application_command 2
  @message_component 3
  @application_command_autocomplete 4
  @modal_submit 5

  defmacro interactions(do: block) do
    quote do
      @spec init() :: DiscordInteractions.config()
      def init do
        var!(interactions) = %{
          global_commands: %{},
          guild_commands: %{},
          message_component_handler: nil,
          modal_submit_handler: nil
        }

        unquote(block)
        var!(interactions)
      end
    end
  end

  defmacro application_command(name, _opts \\ [], do: block) do
    quote do
      var!(command) = %{
        definition: %{name: unquote(name)},
        handler: nil,
        autocomplete_handler: nil,
        guilds: []
      }

      unquote(block)

      var!(interactions) =
        if var!(command).guilds == [] do
          %{
            var!(interactions)
            | global_commands:
                Map.put(var!(interactions).global_commands, unquote(name), var!(command))
          }
        else
          %{
            var!(interactions)
            | guild_commands:
                var!(command).guilds
                |> Enum.reduce(%{}, fn guild, acc ->
                  Map.put(acc, {guild, unquote(name)}, var!(command))
                end)
                |> Map.merge(var!(interactions).guild_commands)
          }
        end
    end
  end

  defmacro name(name) do
    quote do
      var!(command) = %{
        var!(command)
        | definition: Map.put(var!(command).definition, :name, unquote(name))
      }
    end
  end

  defmacro description(description) do
    quote do
      var!(command) = %{
        var!(command)
        | definition: Map.put(var!(command).definition, :description, unquote(description))
      }
    end
  end

  defmacro properties(properties) do
    quote do
      var!(command) = %{
        var!(command)
        | definition: Map.merge(var!(command).definition, unquote(properties))
      }
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

  defmacro __using__(_) do
    quote do
      @behaviour DiscordInteractions.CommandHandler

      import DiscordInteractions

      @spec handle(map()) :: map()
      def handle(
            %{
              "type" => unquote(@application_command),
              "data" => %{"name" => command_name},
              "guild_id" => guild_id
            } = itx
          ) do
        # Handle application command
        case init() do
          %{guild_commands: %{{^guild_id, ^command_name} => %{handler: handler}}}
          when not is_nil(handler) ->
            handler.(itx)

          %{global_commands: %{^command_name => %{handler: handler}}} when not is_nil(handler) ->
            handler.(itx)

          _ ->
            :error
        end
      end

      def handle(%{"type" => unquote(@message_component)} = itx) do
        # Handle message component
        case init() do
          %{message_component_handler: handler} when not is_nil(handler) ->
            handler.(itx)

          _ ->
            :error
        end
      end

      def handle(
            %{
              "type" => unquote(@application_command_autocomplete),
              "data" => %{"name" => command_name},
              "guild_id" => guild_id
            } = itx
          ) do
        # Handle application command autocomplete
        case init() do
          %{guild_commands: %{{^guild_id, ^command_name} => %{autocomplete_handler: handler}}}
          when not is_nil(handler) ->
            handler.(itx)

          %{global_commands: %{^command_name => %{autocomplete_handler: handler}}}
          when not is_nil(handler) ->
            handler.(itx)

          _ ->
            :error
        end
      end

      def handle(%{"type" => unquote(@modal_submit)} = itx) do
        # Handle modal submit
        case init() do
          %{modal_submit_handler: handler} when not is_nil(handler) ->
            handler.(itx)

          _ ->
            :error
        end
      end
    end
  end
end
