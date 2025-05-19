defmodule DiscordInteractions.Util do
  @moduledoc false

  import Plug.Conn

  alias Plug.Conn.Status

  # Channel types
  @guild_text 0
  @dm 1
  @guild_voice 2
  @group_dm 3
  @guild_category 4
  @guild_announcement 5
  @announcement_thread 10
  @public_thread 11
  @private_thread 12
  @guild_stage_voice 13
  @guild_directory 14
  @guild_forum 15
  @guild_media 16

  def error(conn, reason) do
    code = Status.code(reason)

    conn
    |> send_resp(code, Status.reason_phrase(code))
    |> halt()
  end

  @doc """
  Converts a channel type atom or integer to the corresponding Discord API channel type integer.

  ## Examples

      iex> DiscordInteractions.Util.channel_type(:guild_text)
      0

      iex> DiscordInteractions.Util.channel_type(:guild_voice)
      2

      iex> DiscordInteractions.Util.channel_type(5)
      5
  """
  @spec channel_type(atom() | non_neg_integer()) :: non_neg_integer()
  def channel_type(:guild_text), do: @guild_text
  def channel_type(:dm), do: @dm
  def channel_type(:guild_voice), do: @guild_voice
  def channel_type(:group_dm), do: @group_dm
  def channel_type(:guild_category), do: @guild_category
  def channel_type(:guild_announcement), do: @guild_announcement
  def channel_type(:announcement_thread), do: @announcement_thread
  def channel_type(:public_thread), do: @public_thread
  def channel_type(:private_thread), do: @private_thread
  def channel_type(:guild_stage_voice), do: @guild_stage_voice
  def channel_type(:guild_directory), do: @guild_directory
  def channel_type(:guild_forum), do: @guild_forum
  def channel_type(:guild_media), do: @guild_media
  def channel_type(type) when is_integer(type), do: type
  def channel_type(type), do: raise("Invalid channel type: #{inspect(type)}")

  @doc """
  Converts a list of channel type atoms or integers to their corresponding Discord API channel type integers.

  ## Examples

      iex> DiscordInteractions.Util.channel_types([:guild_text, :guild_announcement])
      [0, 5]

      iex> DiscordInteractions.Util.channel_types([0, 5])
      [0, 5]
  """
  @spec channel_types([atom() | non_neg_integer()]) :: [non_neg_integer()]
  def channel_types(types) when is_list(types) do
    Enum.map(types, &channel_type/1)
  end

  def channel_types(nil), do: nil
end
