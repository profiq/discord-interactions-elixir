defmodule DiscordInteractions.CacheBodyReader do
  @moduledoc """
  A body reader implementation for `Plug.Parsers` that caches the raw request body
  in `conn.assigns[:raw_body]` for later use. The `DiscordInteractions.Plug.ValidateRequest`
  plug uses the cached raw body to verify the request signature against Discord's security headers.

  ## Usage

  Configure this body reader in your endpoint or router:

  ```elixir
  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library(),
    body_reader: {DiscordInteractions.CacheBodyReader, :read_body, []}
  ```
  """

  @doc """
  Reads and caches the request body.

  This function wraps `Plug.Conn.read_body/2` and stores the retrieved body
  in `conn.assigns[:raw_body]` as a list of binary chunks.
  """
  @spec read_body(Plug.Conn.t(), Keyword.t()) ::
          {:ok, binary(), Plug.Conn.t()} | {:more, binary(), Plug.Conn.t()} | {:error, term()}
  def read_body(conn, opts) do
    with {:ok, body, conn} <- Plug.Conn.read_body(conn, opts) do
      conn = update_in(conn.assigns[:raw_body], &[body | &1 || []])
      {:ok, body, conn}
    end
  end
end
